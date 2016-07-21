package engine
{
	import flash.events.Event;

	public class UpdateManager
	{
		public var allCallbacks:Vector.<Function> = new Vector.<Function>();
		
		public function UpdateManager()
		{
			trace("UpdateManager OK");
			Locator.mainStage.addEventListener(Event.ENTER_FRAME, update);
		}
		
		protected function update(event:Event):void
		{
			for(var i:int=0; i<allCallbacks.length; i++)
			{
				allCallbacks[i](event);
			}
		}
		
		public function addCallback(callback:Function):void
		{
			allCallbacks.push(callback);
		}
		
		public function removeCallback(callback:Function):void
		{
			var index:int = allCallbacks.indexOf(callback);
			if(index >= 0)
			{
				allCallbacks.splice(index, 1);
			}
		}
	}
}