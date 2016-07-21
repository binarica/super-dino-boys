package engine
{
	import flash.events.Event;
	
	public class SceneEvent extends Event
	{
		public static const ENTER:String = "enter";
		public static const EXIT:String = "exit";
		public static const CHANGE:String = "change";
		
		public var targetScreen:String;
		public var params:Array = new Array();
		
		public function SceneEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return this;
		}
	}
}