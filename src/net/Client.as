package net
{
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.Dictionary;
	
	public class Client
	{
		public static const EVENT_RECEIVE_CLIENT_DATA:String = "receiveClientData";
		public static const EVENT_RECEIVE_MESSAGE:String = "receiveMessage";
		public static const EVENT_GET_ALL_CLIENTS:String = "getAllClients";
		public static const EVENT_CONNECTED:String = "eventConnected";
		public static const EVENT_CLIENT_DISCONNECTED:String = "clientDisconnected";
		public static const EVENT_NEW_CLIENT:String = "clientNewClient";
		public static const EVENT_READ_FROM_SERVER:String = "readFromServer";
		
		/* Mensajes del servidor. */
		public static const MESSAGE_CHANGE_NAME:String = "changeName";
		public static const MESSAGE_GET_ALL_CLIENTS:String = "getAllClients";
		public static const MESSAGE_SEND_TO:String = "sendTo";
		public static const MESSAGE_GET_CLIENT_DATA:String = "getClientData";
		public static const MESSAGE_CLIENT_DISCONNECTED:String = "clientDisconnected";
		public static const MESSAGE_NEW_CLIENT_CONNECTED:String = "newClientConnected";
		public static const MESSAGE_WRITE_IN_SERVER:String = "saveInServer";
		public static const MESSAGE_READ_FROM_SERVER:String = "loadFromServer";
		public static const MESSAGE_CALL_RPC:String = "callRPC";
		
		public var data:ClientData;
		
		/* Puesto que estos eventos se van a ejecutar muy seguido, se hacen estos arreglos para	guardar los listeners para así aumentar el rendimiento.*/
		private var _listenersMessage:Vector.<Function> = new Vector.<Function>();
		private var _listenersReceiveClientData:Vector.<Function> = new Vector.<Function>();
		private var _listenersGetAllClients:Vector.<Function> = new Vector.<Function>();
		private var _listenersConnected:Vector.<Function> = new Vector.<Function>();
		private var _listenersClientDisconnected:Vector.<Function> = new Vector.<Function>();
		private var _listenersNewClient:Vector.<Function> = new Vector.<Function>();
		private var _listenersReadFromServer:Vector.<Function> = new Vector.<Function>();
		/* ********************************************************************************************************************************************* */
		
		//Se usa esta variable en lugar de Socket.connected porque solamente se define como "Conectado" cuando los datos del cliente son creados y recibidos
		//por el servidor correctamente.
		private var _isConnected:Boolean = false;
			/** Obtiene un valor que indica si está conectado al servidor o no. */
			public function get isConnected():Boolean{ return _isConnected; }
		
		/** Lista con todos los RPC. */
		public var allRPCs:Dictionary = new Dictionary();
			
		/** Constructor.
		 * 
		 * @param $name Nombre de este cliente. */
		public function Client($name:String)
		{
			//Los datos de este cliente los manda el servidor.
			data = new ClientData();
			data.socket = new Socket();
			data.name = $name;
		}
		
		/** Conecta al servidor.
		 * 
		 * @param $ip IP del servidor.
		 * @param $port Puerto de conexión. */
		public function connect($ip:String="127.0.0.1", $port:int=21):void
		{
			data.socket.addEventListener(Event.CONNECT, evConnected);
			data.socket.addEventListener(ProgressEvent.SOCKET_DATA, evReceiveData);
			data.socket.addEventListener(Event.CLOSE, evClose);
			data.socket.addEventListener(IOErrorEvent.IO_ERROR, evError);
			data.socket.connect($ip, $port);
		}
		
		/** Escucha un evento de esta clase.</br></br>
		 * 
		 * EVENT_RECEIVE_CLIENT_DATA ===========> Recibe como parámetro un objeto ClientData.</br></br>
		 * EVENT_RECEIVE_MESSAGE ===============> Recibe como parámetro un String con el mensaje y un Object con los parámetros.</br></br>
		 * EVENT_GET_ALL_CLIENTS ===============> Recibe como parámetro un Vector.<ClientData> con los datos de todos los clientes.</br></br>
		 * EVENT_CONNECTED =====================> No recibe parámetros.</br></br>
		 * EVENT_CLIENT_DISCONNECTED ===========> Recibe como parámetro un objeto ClientData con los datos del cliente que se desconectó.</br></br>
		 * EVENT_NEW_CLIENT ====================> Recibe como parámetro un objeto ClientData con los datos del cliente que se conectó.</br></br>
		 * EVENT_READ_FROM_SERVER ==============> Recibe como parámetro un objeto Object con los datos leídos. El objeto puede contener un diccionario, o un objeto con diccionarios adentro dependiendo de los mensajes de quién se estén leyendo. */
		public function addEventListener($type:String, $listener:Function):void
		{
			var listenerIndex:int;
			var code:int = 0;
			
			switch($type)
			{
				case EVENT_RECEIVE_CLIENT_DATA:
					listenerIndex = _listenersReceiveClientData.indexOf($listener);
					listenerIndex == -1 ? _listenersReceiveClientData.push($listener) : code = 1;
					break;
				
				case EVENT_RECEIVE_MESSAGE:
					listenerIndex = _listenersMessage.indexOf($listener);
					listenerIndex == -1 ? _listenersMessage.push($listener) : code = 1;
					break;
				
				case EVENT_GET_ALL_CLIENTS:
					listenerIndex = _listenersGetAllClients.indexOf($listener);
					listenerIndex == -1 ? _listenersGetAllClients.push($listener) : code = 1;
					break;
				
				case EVENT_CONNECTED:
					listenerIndex = _listenersConnected.indexOf($listener);
					listenerIndex == -1 ? _listenersConnected.push($listener) : code = 1;
					break;
				
				case EVENT_CLIENT_DISCONNECTED:
					listenerIndex = _listenersClientDisconnected.indexOf($listener);
					listenerIndex == -1 ? _listenersClientDisconnected.push($listener) : code = 1;
					break;
				
				case EVENT_NEW_CLIENT:
					listenerIndex = _listenersNewClient.indexOf($listener);
					listenerIndex == -1 ? _listenersNewClient.push($listener) : code = 1;
					break;
				
				case EVENT_READ_FROM_SERVER:
					listenerIndex = _listenersReadFromServer.indexOf($listener);
					listenerIndex == -1 ? _listenersReadFromServer.push($listener) : code = 1;
					break;
			}
			
			code != 0 ? trace("[Client.as] El listener que estás tratando de agregar ya existe.") : code = 1;
		}
		
		/** Deja de escuchar un evento de esta clase. */
		public function removeEventListener($type:String, $listener:Function):void
		{
			var listenerIndex:int;
			var code:int = 0;
			
			switch($type)
			{
				case EVENT_RECEIVE_CLIENT_DATA:
					listenerIndex = _listenersReceiveClientData.indexOf($listener);
					listenerIndex != -1 ? _listenersReceiveClientData.splice(listenerIndex, 1) : code = 1;
					break;
				
				case EVENT_RECEIVE_MESSAGE:
					listenerIndex = _listenersMessage.indexOf($listener);
					listenerIndex != -1 ? _listenersMessage.splice(listenerIndex, 1) : code = 1;
					break;
				
				case EVENT_GET_ALL_CLIENTS:
					listenerIndex = _listenersGetAllClients.indexOf($listener);
					listenerIndex != -1 ? _listenersGetAllClients.splice(listenerIndex, 1) : code = 1;
					break;
				
				case EVENT_CONNECTED:
					listenerIndex = _listenersConnected.indexOf($listener);
					listenerIndex != -1 ? _listenersConnected.splice(listenerIndex, 1) : code = 1;
					break;
				
				case EVENT_CLIENT_DISCONNECTED:
					listenerIndex = _listenersClientDisconnected.indexOf($listener);
					listenerIndex != -1 ? _listenersClientDisconnected.splice(listenerIndex, 1) : code = 1;
					break;
				
				case EVENT_NEW_CLIENT:
					listenerIndex = _listenersNewClient.indexOf($listener);
					listenerIndex != -1 ? _listenersNewClient.splice(listenerIndex, 1) : code = 1;
					break;
				
				case EVENT_READ_FROM_SERVER:
					listenerIndex = _listenersReadFromServer.indexOf($listener);
					listenerIndex != -1 ? _listenersReadFromServer.splice(listenerIndex, 1) : code = 1;
					break;
			}
			
			code != 0 ? trace("[Client.as] El listener que estás tratando de quitar no existe.") : null;
		}
		
		/** Escribe un texto en el socket y lo pone en cola para enviar. */
		protected function write($text:String):void {
			try {
				data.socket.writeUTF($text);
			} catch (e:IOError) {
				_isConnected = false;
				trace("[Client.as] Error al escribir un texto: " + e);
			}
		}
		
		/** Escribe un objeto en el socket y lo pone en cola para enviar. */
		protected function writeObject($obj:*):void {
			try {
				data.socket.writeObject($obj);
			} catch (e:IOError) {
				_isConnected = false;
				trace("[Client.as] Error al escribir un objeto: " + e);
			}
		}
		
		/** Envía al servidor los datos en el buffer. */
		protected function flush():void
		{
			try {
				data.socket.flush();
			} catch (e:IOError) {
				_isConnected = false;
				trace("Error al enviar datos: " + e);
			}
		}
		
		/** [AUTORUN] Se ejecuta cuando este cliente se conectó satisfactoriamente al servidor. En este momento aún no se
		 * obtuvieron los datos de este cliente. */
		private function evConnected(ev:Event):void
		{
			write(MESSAGE_CHANGE_NAME);
			write(data.name);
			data.socket.flush();
			
			write(MESSAGE_GET_CLIENT_DATA);
			data.socket.flush();
			
			//LO PONEMOS ONLINE SOLO CUANDO RECIBE LOS DATOS DEL CLIENTE CORRECTAMENTE.
		}
		
		/** [AUTORUN] Se activa cuando se cierra la conexión con el servidor. */
		protected function evClose(ev:Event):void
		{
			_isConnected = false;
		}
		
		/** [AUTORUN] Se activa cuando hay un error en la conexión. EJ: Si no se pudo conectar al servidor. */
		protected function evError(ev:IOErrorEvent):void
		{
			trace("[Client.as] Hubo un error: " + ev.text);
		}
		
		/** [AUTORUN] Se activa cada vez que se recibe un dato del servidor. */
		protected function evReceiveData(ev:ProgressEvent):void
		{
			try {
				//Se pone este bucle porque si se envía más de un paquete en el mismo frame sólo se ejecutaría el primero.
				while(data.socket.bytesAvailable > 0)
				{
					var command:String = data.socket.readUTF();
					var i:int;
					
					switch(command)
					{
						case MESSAGE_SEND_TO:
							var message:String = data.socket.readUTF();
							var params:Object = data.socket.readObject();
							
							for(i=_listenersMessage.length-1; i >= 0 ; i--)
							{
								_listenersMessage[i](message, params);
							}
							break;
						
						case MESSAGE_GET_ALL_CLIENTS:
							var numClients:int = data.socket.readInt();
							var clients:Vector.<ClientData> = new Vector.<ClientData>();
							for(i=numClients-1; i >= 0 ; i--)
							{
								var d:ClientData = new ClientData();
								d.ip = data.socket.readUTF();
								d.port = int(data.socket.readUTF());
								d.name = data.socket.readUTF();
								clients.push(d);
							}
							
							for(i=_listenersGetAllClients.length-1; i >= 0 ; i--)
							{
								_listenersGetAllClients[i]( clients );
							}
							
							break;
						
						case MESSAGE_GET_CLIENT_DATA:
							data.ip = data.socket.readUTF();
							data.port = data.socket.readInt();
							data.name = data.socket.readUTF();
							
							for(i=_listenersReceiveClientData.length-1; i >= 0 ; i--)
							{
								_listenersReceiveClientData[i]();
							}
							
							//Si no estaba online, lo marcamos ahora como conectado y llamamos a todos los listeners que correspondan.
							if(!_isConnected)
							{
								_isConnected = true;
								for(i=_listenersConnected.length-1; i >= 0 ; i--)
								{
									_listenersConnected[i]();
								}
							}
							break;
						
						case MESSAGE_CLIENT_DISCONNECTED:
							var clientDataReceive:* = data.socket.readObject();
							var clientDataDisconnected:ClientData = new ClientData();
							clientDataDisconnected.ip = clientDataReceive.ip;
							clientDataDisconnected.port = clientDataReceive.port;
							clientDataDisconnected.name = clientDataReceive.name;
							
							for(i=_listenersClientDisconnected.length-1; i >= 0 ; i--)
							{
								_listenersClientDisconnected[i]( clientDataDisconnected );
							}
							break;
						
						case MESSAGE_NEW_CLIENT_CONNECTED:
							var dataNewClient:ClientData = new ClientData();
							dataNewClient.ip = data.socket.readUTF();
							dataNewClient.port = data.socket.readInt();
							dataNewClient.name = data.socket.readUTF();
							
							for(i=_listenersNewClient.length-1; i >= 0; i--)
							{
								_listenersNewClient[i]( dataNewClient );
							}
							break;
						
						case MESSAGE_CALL_RPC:
							/*var name:String = data.socket.readUTF();
							var p:Array = data.socket.readObject() as Array;*/
							break;
						
						case MESSAGE_READ_FROM_SERVER:
							var from:String = data.socket.readUTF();
							var readData:* = data.socket.readObject();
							var dataParsed:Dictionary = new Dictionary();
							
							if(from == "[*]")
							{
								dataParsed = readData as Dictionary;
							}else{
								from = from.slice(1, from.length-1);
								dataParsed[from] = readData;
							}
							
							for(i=_listenersReadFromServer.length-1; i >= 0; i--)
							{
								_listenersReadFromServer[i]( dataParsed );
							}
							break;
					}
				}
			}
			catch (e:IOError)
			{
				trace("[Client.as] Error en el socket: " + e);
			}
			catch (e:EOFError)
			{
				//trace("[Client.as] Error de final de archivo: " + e);
			}
			catch(e:Error)
			{
				trace("[Client.as] Error en listener: " + e.message + "\n\n" + e.getStackTrace());
			}
		}
		
		/** Registra una función para que pueda ser llamada desde la red. */
		public function registerRPC($name:String, $rpc:Function):void
		{
			allRPCs[$name] = $rpc;
		}
		
		public function callRPC($name:String, ...$params):void
		{
			execRPC($name, $params);
			/*write(MESSAGE_CALL_RPC);
			write($name);
			writeObject($params);
			flush();*/
		}
		
		private function execRPC(name:String, params:Array):void
		{
			var rpc:Function = allRPCs[name];
			if(rpc != null)
			{
				rpc.apply(this, params);
			}else
			{
				trace("RPC \"" + name + "\" no existe.");
			}
		}
		
		/** Cambia el nombre de este cliente en el servidor. */
		public function changeName($name:String):void
		{
			write(MESSAGE_CHANGE_NAME);
			write($name);
			flush();
		}
		
		/** Envía un mensaje a un cliente.
		 * 
		 * @param $name Nombre del cliente a quien se envía el mensaje. Si se pasa "*" se envía a todos los clientes.
		 * @param $message Mensaje que se envía.
		 * @param $args Objeto que contiene variables con sus respectivos valores. */
		public function sendMessageTo($name:String, $message:String, $params:Object = null):void
		{
			write(MESSAGE_SEND_TO);
			write(data.name);
			write($name);
			write($message);
			writeObject($params);
			flush();
		}
		
		/** Pide al servidor la lista de todos los clientes conectados. */
		public function getAllClient():void
		{
			write(MESSAGE_GET_ALL_CLIENTS);
			flush();
		}
		
		/** Escribe datos en el servidor. */
		public function writeInServer($data:*):void
		{
			write(MESSAGE_WRITE_IN_SERVER);
			write(data.name);
			writeObject($data);
			flush();
		}
		
		/** Lee datos desde el servidor de un cliente específico o de todos.
		 * El dato que se traerá del servidor será un "Dictionary" que tendrá como clave el nombre del cliente que se pidió (en caso de pasar uno), y como valor los datos que ese cliente guardó en el servidor (tipo "Object").
		 * En el caso de pasar como parámetro "*", el objeto "Dictionary" estará formado por las claves de cada uno de los clientes que guardaron datos y están conectados (si algún cliente se desconecta, sus datos se borran,
		 * a menos que se hayan guardado como permanentes). En el caso de que el cliente pedido no exista, se devuelve "null".
		 * 
		 * @param $id ID del cliente del cual se van a leer los datos (si se pasa "*" se toma como todos los usuarios). */
		public function readFromServer($id:String):void
		{
			write(MESSAGE_READ_FROM_SERVER);
			write($id);
			flush();
		}
	}
}
