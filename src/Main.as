package
{
	import flash.events.Event;
	import engine.Locator;
	import engine.SoundManager;
	
	[SWF(width="1440", height="900", frameRate="30", backgroundColor="#000000")]
	public class Main extends Locator
	{	
		public function Main()
		{
			Locator.assetManager.loadLinks("links.txt");
			Locator.assetManager.addEventListener("all_assets_complete", gotoGame);
		}
		
		public function gotoGame(event:Event):void
		{
			Locator.assetManager.removeEventListener("all_assets_complete", gotoGame);
			
			trace("Game ON!");
			
			Locator.sceneManager.registerScene("Menu", SceneMenu);
			Locator.sceneManager.registerScene("Game", SceneGame);
			Locator.sceneManager.registerScene("Options", SceneOptions);
			Locator.sceneManager.registerScene("Tutorial", SceneTutorial);
			
			Locator.sceneManager.loadScene("Menu");			
		}
	}
}