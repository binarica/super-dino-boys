package engine
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;

	public class SceneManager
	{
		public var currentScreen:CustomScene;
		public var allScreens:Dictionary = new Dictionary();
		public var screenContainer:Sprite = new Sprite();
		
		public function SceneManager()
		{
			trace("SceneManager OK");
			
			Locator.updateManager.addCallback(onUpdate);
			Locator.mainStage.addChild(screenContainer);
			
			Locator.console.registerCommand("loadscreen", loadScene, "Loads another screen.");
		}
		
		protected function onUpdate(event:Event):void
		{
			if(currentScreen != null)
			{
				currentScreen.update();
			}
		}
		
		public function registerScene(name:String, screenClass:Class):void
		{
			allScreens[name] = screenClass;
		}
		
		public function loadScene(name:String):void
		{
			if(currentScreen != null)
			{
				currentScreen.exit();
				currentScreen = null;
			}
			
			var scrClass:Class = allScreens[name];
			currentScreen = new scrClass();
			currentScreen.addEventListener("change", evChange);
			currentScreen.enter();
		}
		
		protected function evChange(event:SceneEvent):void
		{
			currentScreen.removeEventListener("change", evChange);
			loadScene(event.targetScreen);
		}
	}
}