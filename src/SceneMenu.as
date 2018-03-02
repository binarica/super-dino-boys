package
{
	import engine.CustomScene;
	import engine.Locator;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class SceneMenu extends CustomScene
	{
		private var start:MovieClip;
		private var options:MovieClip;
		private var tutorial:MovieClip;
		
		public function SceneMenu()
		{
			super("Menu");
		}
		
		override public function enter():void
		{
			super.enter();
			
			start = new MovieClip();
			start = Locator.assetManager.getMovieClip("StartButton");
			Locator.mainStage.addChild(start);
			start.x = 45;
			start.y = 750;
			start.addEventListener(MouseEvent.MOUSE_DOWN, startDown);
			start.addEventListener(MouseEvent.MOUSE_UP, startUp);
			
			options = new MovieClip();
			options = Locator.assetManager.getMovieClip("OptionsButton");
			Locator.mainStage.addChild(options);
			options.x = 490;
			options.y = 750;
			options.addEventListener(MouseEvent.MOUSE_DOWN, optionsDown);
			options.addEventListener(MouseEvent.MOUSE_UP, optionsUp);
			
			
			tutorial = new MovieClip();
			tutorial = Locator.assetManager.getMovieClip("TutorialButton");
			Locator.mainStage.addChild(tutorial);
			tutorial.x = 950;
			tutorial.y = 750;
			tutorial.addEventListener(MouseEvent.MOUSE_DOWN, tutorialDown);
			tutorial.addEventListener(MouseEvent.MOUSE_UP, tutorialUp);
			
			Locator.soundManager.play(SoundID.MENU, C.ENV_VOLUME, 99999);
		}
		
		private function startDown(e:MouseEvent):void
		{
			start.gotoAndStop("Press");
		}
		
		private function startUp(e:MouseEvent):void
		{
			start.gotoAndStop("Normal");
			changeScene("Game");
		}
		
		private function optionsDown(e:MouseEvent):void
		{
			options.gotoAndStop("Press");
		}
		
		private function optionsUp(e:MouseEvent):void
		{
			options.gotoAndStop("Normal");
			changeScene("Options");
		}
		
		private function tutorialDown(e:MouseEvent):void
		{
			tutorial.gotoAndStop("Press");
		}
		
		private function tutorialUp(e:MouseEvent):void
		{
			tutorial.gotoAndStop("Normal");
			changeScene("Tutorial");
		}
		
		override public function exit():void
		{
			super.exit();
			model.stop();
			model = null;
			
			Locator.soundManager.stop(SoundID.MENU);
			
			if (start.parent != null && tutorial.parent != null && options.parent != null)
			{
				start.parent.removeChild(start);
				options.parent.removeChild(options);
				tutorial.parent.removeChild(tutorial);
				start.removeEventListener(MouseEvent.MOUSE_DOWN, startDown);
				start.removeEventListener(MouseEvent.MOUSE_UP, startUp);
				options.removeEventListener(MouseEvent.MOUSE_DOWN, optionsDown);
				options.removeEventListener(MouseEvent.MOUSE_UP, optionsUp);
				tutorial.removeEventListener(MouseEvent.MOUSE_DOWN,tutorialDown);
				tutorial.removeEventListener(MouseEvent.MOUSE_UP,tutorialUp);
			}
		}
	}
}