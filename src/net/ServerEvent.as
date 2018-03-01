package net
{
	import flash.events.Event;
	
	public class ServerEvent extends Event
	{
		public static const CONNECTED:String = "connected";
		public static const DISCONNECTED:String = "disconnected";
		public static const UPDATE_CLIENT_DATA:String = "update client data";
		
		public function ServerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return this;
		}
	}
}