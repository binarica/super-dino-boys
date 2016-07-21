package engine
{
	public class CommandData
	{
		/** Comando que se va a guardar. */
		public var command:Function;
		
		/** Nombre del comando. */
		public var name:String;
		
		public var parameters:Array = new Array();
		public var description:String;
	}
}