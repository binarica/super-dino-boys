package net
{
	import flash.net.Socket;

	public class ClientData
	{
		/** Nombre de este cliente. */
		public var name:String;
		
		/** Socket de este cliente. */
		public var socket:Socket;
		
		/** IP desde la que se conectó. */
		public var ip:String;
		
		/** Puerto que utiliza. */
		public var port:int;
		
		/** Muestra el nombre de esta conexión seguido del caracter que se usa para separar las conexiones. */
		public function toString():String
		{
			return name + " - " + ip;
		}
	}
}