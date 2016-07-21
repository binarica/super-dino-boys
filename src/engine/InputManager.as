package engine
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;

	public class InputManager
	{
		public var keys:Array = new Array();
		public var keysByName:Dictionary = new Dictionary();
		public var sequence:Array = new Array();
		
		public var timeToClear:int = 500;
		public var currentTimeToClear:int = timeToClear;
		
		public function InputManager()
		{
			trace("InputManager OK");
			
			Locator.mainStage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			Locator.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			
			Locator.updateManager.addCallback(clearSequence);
		}
		
		private function clearSequence(event:Event):void
		{
			currentTimeToClear -= 1000 / Locator.mainStage.frameRate;
			if(currentTimeToClear <= 0)
			{
				currentTimeToClear = timeToClear;
				sequence = [];
			}
		}
		
		public function setRelation(name:String, keyCode:int):void
		{
			var k:Key = keys[keyCode];
			
			if(k == null)
			{
				k = new Key();
				keys[keyCode] = k;
			}
			
			keysByName[name] = k;
		}
		
		protected function keyDown(event:KeyboardEvent):void
		{
			var k:Key = keys[event.keyCode];
			if(k == null)
			{
				k = new Key();
				keys[event.keyCode] = k;
			}
			
			if(!k.isPressing)
			{
				k.press();
				currentTimeToClear = timeToClear;
				sequence.push(event.keyCode);
			}
			
			/*if(k != null)
			{
				if(!k.isPressing)
				{
					k.press();
					sequence.push(event.keyCode);
				}
			}else{
				k = new Key();
				keys[event.keyCode] = k;
				k.press();
			}*/
		}
		
		protected function keyUp(event:KeyboardEvent):void
		{
			var k:Key = keys[event.keyCode];
			if(k != null)
			{
				k.release();
			}else
			{
				k = new Key();
				keys[event.keyCode] = k;
			}
		}
		
		public function getKeyPressing(keyCode:int):Boolean
		{
			return keys[keyCode] != null ? keys[keyCode].isPressing : false;
		}
		
		public function getWasKeyPressed(keyCode:int):Boolean
		{
			return keys[keyCode] != null ? keys[keyCode].wasPressed : false;
		}
		
		public function getWasKeyReleased(keyCode:int):Boolean
		{
			return keys[keyCode] != null ? keys[keyCode].wasReleased : false;
		}
		
		public function getKeyValue(keyCode:int):Number
		{
			return keys[keyCode] != null ? keys[keyCode].currentSpeed : 0;
		}
		
		public function getKeyPressingByName(name:String):Boolean
		{
			return keysByName[name] != null ? keysByName[name].isPressing : false;
		}
		
		public function getWasKeyPressedByName(name:String):Boolean
		{
			return keysByName[name] != null ? keysByName[name].wasPressed : false;
		}
		
		public function getWasKeyReleasedByName(name:String):Boolean
		{
			return keysByName[name] != null ? keysByName[name].wasReleased : false;
		}
		
		public function getKeyValueByName(name:String):Number
		{
			return keysByName[name] != null ? keysByName[name].currentSpeed : 0;
		}
		
		public function compareSequence(s:Array):Boolean
		{
			return s.toString() == sequence.toString();
		}
	}
}