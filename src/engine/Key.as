package engine
{
	import flash.events.Event;

	public class Key
	{
		public var isPressing:Boolean;
		public var wasPressed:Boolean;
		public var wasReleased:Boolean;
		
		public var speed:Number = 0.01;
		public var currentSpeed:Number = 0;
		
		public function Key()
		{
		}
		
		public function press():void
		{
			isPressing = true;
			wasPressed = true;
			
			Locator.updateManager.addCallback(evCheckKeyPressed);
			Locator.updateManager.addCallback(evSpeedUp);
			Locator.updateManager.removeCallback(evSpeedDown);
			//Locator.mainStage.addEventListener(Event.ENTER_FRAME, evCheckKeyPressed);
		}
		
		private function evSpeedUp(event:Event):void
		{
			currentSpeed += speed;
			if(currentSpeed > 1)
			{
				currentSpeed = 1;
				Locator.updateManager.removeCallback(evSpeedUp);
			}
		}
		
		protected function evCheckKeyPressed(event:Event):void
		{
			wasPressed = false;
			
			Locator.updateManager.removeCallback(evCheckKeyPressed);
			//Locator.mainStage.removeEventListener(Event.ENTER_FRAME, evCheckKeyPressed);
		}
		
		public function release():void
		{
			isPressing = false;
			wasReleased = true;
			
			Locator.updateManager.addCallback(evCheckKeyReleased);
			Locator.updateManager.addCallback(evSpeedDown);
			Locator.updateManager.removeCallback(evSpeedUp);
			//Locator.mainStage.addEventListener(Event.ENTER_FRAME, evCheckKeyReleased);
		}
		
		private function evSpeedDown(event:Event):void
		{
			currentSpeed -= speed;
			if(currentSpeed < 0)
			{
				currentSpeed = 0;
				Locator.updateManager.removeCallback(evSpeedDown);
			}
		}
		
		protected function evCheckKeyReleased(event:Event):void
		{
			wasReleased = false;
			
			Locator.updateManager.removeCallback(evCheckKeyReleased);
			//Locator.mainStage.removeEventListener(Event.ENTER_FRAME, evCheckKeyReleased);
		}
	}
}