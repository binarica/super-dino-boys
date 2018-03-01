package net
{
	import flash.errors.EOFError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.Dictionary;

	[Event(name="connected", type="net.ServerEvent")]
	[Event(name="disconnected", type="net.ServerEvent")]
	[Event(name="update client data", type="net.ServerEvent")]
	public class GameServer extends EventDispatcher
	{
		public static const NAME:String = "[*** SERVER ***]";
		
		public static const CHARACTER_GET_ALL_CLIENTS:String = "@/>";
		
		/** Representa el socket del servidor. */
		private var _socket:ServerSocket;
		
		/** Lista de todos los clientes conectados. */
		public var allClients:Vector.<ClientData>;
		
		/** Todos los datos que almacenaron los clientes (se borran si se desconectan). */
		public var allDataStoredFromClients:Dictionary = new Dictionary();
		
		/** Obtiene un valor que indica si el servidor está online. */
		public function get isOnline():Boolean{ return _socket.listening; }
		
		/** Constructor. Inicializa el socket y la lista de clientes. */
		public function GameServer()
		{
			_socket = new ServerSocket();
			allClients = new Vector.<ClientData>();
		}
		
		/** Inicia este servidor.
		 * 
		 * @param $ip IP de esta conexión.
		 * @param $port Puerto que se utiliza. */
		public function start($ip:String="127.0.0.1", $port:int=21):void
		{
			//Chequea si hay una conexión activa. Si la hay, la cerramos y creamos una nueva.
			if (_socket.bound)
			{
				_socket.removeEventListener(ServerSocketConnectEvent.CONNECT, evConnect);
				_socket.close();
				_socket = new ServerSocket();
			}
			
			//Bindeamos con el puerto y la IP.
			_socket.bind($port, $ip);
			
			//Agregamos un listener para saber cuándo un cliente se conectó a este server.
			_socket.addEventListener(ServerSocketConnectEvent.CONNECT, evConnect);
			
			//Iniciamos la escucha de nuevas conexiones.
			_socket.listen();
		}
		
		/** Detiene el servidor. */
		public function stop():void
		{
			if (_socket.bound)
			{
				_socket.close();
				_socket = new ServerSocket();
			}
		}
		
		/** [AUTORUN] Se ejecuta cuando se conecta un cliente. */
		protected function evConnect($event:ServerSocketConnectEvent):void
		{
			//Construimos los datos del cliente que se acaba de conectar.
			var newClient:ClientData = new ClientData();
			newClient.name = "<< NoName >> - ID: " + Math.random();
			newClient.socket = $event.socket;
			newClient.ip = $event.socket.remoteAddress;
			newClient.port = $event.socket.remotePort;
			//**********************************************************
			
			//Agregamos los listeners para controlar la actividad del cliente.
			newClient.socket.addEventListener(ProgressEvent.SOCKET_DATA, evReceiveData); //Cada vez que se reciben datos del cliente.
			newClient.socket.addEventListener(Event.CLOSE, evClientClose); //Cuando un cliente cierra la conexión.
			
			//Agregamos al nuevo cliente.
			allClients.push(newClient);
			
			dispatchEvent(new ServerEvent( ServerEvent.CONNECTED ));
		}
		
		/** [AUTORUN] Se activa cuando un cliente se desconecta. */
		protected function evClientClose($event:Event):void
		{
			var client:Socket = $event.target as Socket;
			client.removeEventListener(Event.CLOSE, evClientClose);
			client.removeEventListener(ProgressEvent.SOCKET_DATA, evReceiveData);
			
			var cd:ClientData = getClientDataBySocket(client);
			allClients.splice(allClients.indexOf( cd ), 1);
			
			//Borramos los datos que almaceno este cliente.
			delete allDataStoredFromClients[cd.name];
			
			//Enviamos los datos del cliente desconectado.
			for(var i:int=allClients.length-1; i>=0; i--)
			{
				allClients[i].socket.writeUTF(Client.MESSAGE_CLIENT_DISCONNECTED);
				allClients[i].socket.writeObject({ip:cd.ip, port:cd.port, name:cd.name});
				allClients[i].socket.flush();
			}
			
			dispatchEvent(new ServerEvent( ServerEvent.DISCONNECTED ));
		}
		
		/** [AUTORUN] Se activa cuando se recibe un dato desde un cliente. */
		protected function evReceiveData($event:ProgressEvent):void
		{
			var client:Socket = $event.target as Socket;		
			try {
				
				//Se pone este bucle porque si se envía más de un paquete en el mismo frame sólo se ejecutaría el primero.
				while(client.bytesAvailable > 0)
				{
					var messageType:String = client.readUTF();
					
					switch (messageType)
					{
						case Client.MESSAGE_SEND_TO:
							var from:String = client.readUTF();
							var to:String = client.readUTF();
							var message:String = client.readUTF();
							var params:* = (client.bytesAvailable > 0) ? client.readObject() : null;
							sendMessageTo(to, from, message, params);
							break;
						
						case Client.MESSAGE_CHANGE_NAME:
							getClientDataBySocket(client).name = client.readUTF();
							break;
						
						case Client.MESSAGE_GET_ALL_CLIENTS:
							client.writeUTF(Client.MESSAGE_GET_ALL_CLIENTS);
							client.writeInt(allClients.length);
							
							for(var i:int=allClients.length-1; i >= 0; i--)
							{
								client.writeUTF(allClients[i].ip);
								client.writeUTF(allClients[i].port.toString());
								client.writeUTF(allClients[i].name);
							}
							
							client.flush();
							break;
						
						case Client.MESSAGE_GET_CLIENT_DATA:
							//En esta instancia el cliente está conectado.
							var clientData:ClientData = getClientDataBySocket(client);
							client.writeUTF(Client.MESSAGE_GET_CLIENT_DATA);
							client.writeUTF(clientData.ip);
							client.writeInt(clientData.port);
							client.writeUTF(clientData.name);
							client.flush();
							
							//Notificamos a todos que un cliente nuevo se conecto.
							notifyNewClient( clientData );
							
							dispatchEvent( new ServerEvent( ServerEvent.UPDATE_CLIENT_DATA ));
							break;
						
						case Client.MESSAGE_WRITE_IN_SERVER:
							var clientID:String = client.readUTF();
							var dataToSave:* = client.readObject();
							allDataStoredFromClients[clientID] = dataToSave;
							break;
						
						case Client.MESSAGE_READ_FROM_SERVER:
							var getDataFromName:String = client.readUTF(); //Los datos de quién tenemos que dar.
							client.writeUTF(Client.MESSAGE_READ_FROM_SERVER);
							
							if(getDataFromName == "*")
							{
								client.writeUTF("[*]");
								client.writeObject( allDataStoredFromClients );
							}else
							{
								client.writeUTF("[" + getDataFromName + "]");
								client.writeObject( allDataStoredFromClients[getDataFromName] );
							}
							
							client.flush();
							break;
					}
				}
			} catch (e:EOFError) {
				trace( "Se llegó al final del archivo.");
			}
			
			//trace(client.bytesAvailable);
		}
		
		/** Obtiene la información de un cliente por su socket.
		 * 
		 * @param $socket Socket del cliente. */
		public function getClientDataBySocket($socket:Socket):ClientData
		{
			for(var i:int=allClients.length-1; i>=0; i--)
			{
				if(allClients[i].socket == $socket)
				{
					return allClients[i];
				}
			}
			
			return null;
		}
		
		/** Obtiene la información de un cliente conectado por su nombre.
		 * 
		 * @param $name Nombre del cliente. */
		public function getClientDataByName($name:String):ClientData
		{
			for(var i:int=allClients.length-1; i>=0; i--)
			{
				if(allClients[i].name == $name)
				{
					return allClients[i];
				}
			}
			
			return null;
		}
		
		/** Envía un mensaje al cliente.
		 * 
		 * @param $toClient Nombre del cliente al que se envía el mensaje. Si se especifíca "*" se envía a todos los cliente.
		 * @param $fromClient Nombre del cliente que envía este mensaje.
		 * @param $message Mensaje que se envía al cliente.
		 * @param $args Argumentos que se pasan al cliente.
		 * @param $includeMe Especifíca si se manda el mensaje al mismo cliente que hizo este llamado. */
		public function sendMessageTo($toClient:String, $fromClient:String, $message:String, $args:Object=null):void
		{
			var i:int;
			var client:ClientData;
			
			//Se hace el IF acá y se repite el bloque para no hacer el chequeo en cada paso y así ahorrar rendimiento.
			if($toClient == "*")
			{
				for(i=allClients.length-1; i>=0; i--)
				{
					client = allClients[i];
					if(client.name != $fromClient) //No reenvía el mensaje al cliente que lo emitió.
					{
						client.socket.writeUTF(Client.MESSAGE_SEND_TO);
						client.socket.writeUTF($message);
						client.socket.writeObject($args);
						client.socket.flush();
					}
				}
			}else
			{
				for(i=allClients.length-1; i>=0; i--)
				{
					client = allClients[i];
					if(client.name == $toClient)
					{
						client.socket.writeUTF(Client.MESSAGE_SEND_TO);
						client.socket.writeUTF($message);
						client.socket.writeObject($args);
						client.socket.flush();
						return;
					}
				}
			}
		}
		
		/** Envía un mensaje a todos notificando que un cliente nuevo se conectó.
		 * 
		 * @param $newClient Cliente que se acaba de conectar. */
		public function notifyNewClient( $newClient:ClientData ):void
		{
			//sendMessageTo("*", NAME, MESSAGE_NEW_CLIENT_CONNECTED, {ip:clientData.ip, port:clientData.port, name:clientData.name});
			for(var i:int=allClients.length-1; i >= 0; i--)
			{
				if($newClient.name != allClients[i].name)
				{
					allClients[i].socket.writeUTF(Client.MESSAGE_NEW_CLIENT_CONNECTED);
					allClients[i].socket.writeUTF($newClient.ip);
					allClients[i].socket.writeInt($newClient.port);
					allClients[i].socket.writeUTF($newClient.name);
					allClients[i].socket.flush();
				}
			}
		}
	}
}