package
{
	import engine.CustomScene;
	import engine.Locator;
	
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;

	public class SceneOptions extends CustomScene
	{
		private var backButton:MovieClip;
		private var fullscreenOnButton:MovieClip;
		private var fullscreenOffButton:MovieClip;
		private var soundOnButton:MovieClip;
		private var soundOffButton:MovieClip;
		
		public function SceneOptions()
		{
			super("Options");
		}
		
		override public function enter():void
		{
			super.enter();
			
			backButton = new MovieClip();
			backButton = Locator.assetManager.getMovieClip("BackButton");
			Locator.mainStage.addChild(backButton);
			backButton.x = 1230;
			backButton.y = 800;
			backButton.addEventListener(MouseEvent.MOUSE_DOWN,backDown);
			backButton.addEventListener(MouseEvent.MOUSE_UP, backUp);
			
			fullscreenOffButton = new MovieClip();
			fullscreenOffButton = Locator.assetManager.getMovieClip("FullscreenOff");
			Locator.mainStage.addChild(fullscreenOffButton);
			fullscreenOffButton.x = 765;
			fullscreenOffButton.y = 165;
			fullscreenOffButton.addEventListener(MouseEvent.CLICK, fullscreenOff);
			
			fullscreenOnButton = new MovieClip();
			fullscreenOnButton = Locator.assetManager.getMovieClip("FullscreenOn");
			Locator.mainStage.addChild(fullscreenOnButton);
			fullscreenOnButton.x = 300;
			fullscreenOnButton.y = 165;
			fullscreenOnButton.addEventListener(MouseEvent.CLICK, fullscreenOn);
			
			soundOffButton = new MovieClip();
			soundOffButton = Locator.assetManager.getMovieClip("SoundOff");
			Locator.mainStage.addChild(soundOffButton);
			soundOffButton.x = 440;
			soundOffButton.y = 450;
			soundOffButton.addEventListener(MouseEvent.CLICK, soundOff);
			
			soundOnButton = new MovieClip();
			soundOnButton = Locator.assetManager.getMovieClip("SoundOn");
			Locator.mainStage.addChild(soundOnButton);
			soundOnButton.x = 220;
			soundOnButton.y = 450;
			soundOnButton.addEventListener(MouseEvent.CLICK, soundOn);
			
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
		
		private function soundOff(e:MouseEvent):void
		{
			soundOffButton.gotoAndStop("Press");
			soundOnButton.gotoAndStop("Normal");
			Locator.soundManager.muteSound();
		}
		
		private function soundOn(e:MouseEvent):void
		{
			soundOnButton.gotoAndStop("Press");
			soundOffButton.gotoAndStop("Normal");
			Locator.soundManager.unMuteSound();
		}
		
		private function fullscreenOff(e:MouseEvent):void
		{
			fullscreenOffButton.gotoAndStop("Press");
			fullscreenOnButton.gotoAndStop("Normal");
			Locator.mainStage.displayState = StageDisplayState.NORMAL;
		}
		
		private function fullscreenOn(e:MouseEvent):void
		{
			fullscreenOnButton.gotoAndStop("Press");
			fullscreenOffButton.gotoAndStop("Normal");
			Locator.mainStage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}
				
		override public function exit():void
		{
			super.exit();
			model.stop();
			model = null;
			
			Locator.soundManager.stop(SoundID.TUTORIAL);
			
			if (backButton.parent != null && fullscreenOffButton.parent != null && fullscreenOnButton.parent != null && soundOffButton.parent != null && soundOnButton.parent != null)
			{
				backButton.parent.removeChild(backButton);
				backButton.removeEventListener(MouseEvent.MOUSE_DOWN,backDown);
				backButton.removeEventListener(MouseEvent.MOUSE_UP, backUp);

				fullscreenOffButton.parent.removeChild(fullscreenOffButton);
				fullscreenOffButton.removeEventListener(MouseEvent.CLICK, fullscreenOff);
				fullscreenOnButton.parent.removeChild(fullscreenOnButton);
				fullscreenOnButton.removeEventListener(MouseEvent.CLICK, fullscreenOn);
				
				soundOffButton.parent.removeChild(soundOffButton);
				soundOffButton.removeEventListener(MouseEvent.CLICK, soundOff);
				soundOnButton.parent.removeChild(soundOnButton);
				soundOnButton.removeEventListener(MouseEvent.CLICK, soundOn);				
			}
		}
	}
}