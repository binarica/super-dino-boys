package
{
	import engine.CustomScene;
	import engine.Locator;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class SceneTutorial extends CustomScene
	{
		private var backButton:MovieClip;
		
		public function SceneTutorial()
		{
			super("Tutorial");
		}
		
		override public function enter():void
		{
			super.enter();
			
			backButton = new MovieClip();
			backButton = Locator.assetManager.getMovieClip("BackButton");
			Locator.mainStage.addChild(backButton);
			backButton.x = 1250;
			backButton.y = 750;
			backButton.addEventListener(MouseEvent.MOUSE_DOWN,backDown);
			backButton.addEventListener(MouseEvent.MOUSE_UP,backUp);
			
			Locator.soundManager.play(SoundID.TUTORIAL, C.ENV_VOLUME, 99999);
		}
		
		private function backDown(e:MouseEvent):void
		{
			backButton.gotoAndStop("Press");
		}
		
		private function backUp(e:MouseEvent):void
		{
			backButton.gotoAndStop("Normal");
			changeScene("Menu");
		}
		
		override public function exit():void
		{
			super.exit();
			model.stop();
			model = null;
			
			Locator.soundManager.stop(SoundID.TUTORIAL);
			
			if(backButton.parent != null)
			{
				backButton.parent.removeChild(backButton);
				backButton.removeEventListener(MouseEvent.MOUSE_DOWN,backDown);
				backButton.removeEventListener(MouseEvent.MOUSE_UP,backUp);
			}
		}
	}
}