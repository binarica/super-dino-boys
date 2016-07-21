package engine
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;

	public class Locator extends Sprite
	{		
		public static var mainStage:Stage;
		
		public static var console:Console;
		public static var assetManager:AssetManager;
		public static var soundManager:SoundManager;
		public static var updateManager:UpdateManager;
		public static var sceneManager:SceneManager;
		public static var inputManager:InputManager;
		public static var saveManager:SaveManager;
		
		public function Locator()
		{
			trace("Engine OK");
			
			mainStage = stage;
			mainStage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			mainStage.scaleMode = StageScaleMode.SHOW_ALL;
			
			console = new Console();
			assetManager = new AssetManager();
			soundManager = new SoundManager();
			updateManager = new UpdateManager();
			sceneManager = new SceneManager();
			inputManager = new InputManager();
			saveManager = new SaveManager();		
		}
	}
}