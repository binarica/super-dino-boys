package
{
	import engine.Locator;
	
	import org.bytearray.gif.player.GIFPlayer;

	public class Level
	{
		//private var background:GIFPlayer = new GIFPlayer(); more elegant!
		
		private var _level1:GIFPlayer = new GIFPlayer();
		private var _level2:GIFPlayer = new GIFPlayer();
		private var _level3:GIFPlayer = new GIFPlayer();
		
		public function Level()
		{

		}
		
		public function init(levNum:int):void
		{
			_level1 = Locator.assetManager.getGIFImage("bg1");
			_level2 = Locator.assetManager.getGIFImage("bg2");
			_level3 = Locator.assetManager.getGIFImage("bg3");
			
			_level1.width = C.GAME_WIDTH;
			_level1.height = C.GAME_HEIGHT;
			_level2.width = C.GAME_WIDTH;
			_level2.height = C.GAME_HEIGHT;
			_level3.width = C.GAME_WIDTH;
			_level3.height = C.GAME_HEIGHT;
			
			changeLevel(levNum);
		}
		
		public function changeLevel(levNum:int):void
		{
			destroy();
			
			switch (levNum)
			{
				case 1:
					Locator.mainStage.addChild(_level1);
					break;
				case 2:
					Locator.mainStage.addChild(_level2);
					break;
				case 3:
					Locator.mainStage.addChild(_level3);
					break;
			}	
		}
		
		public function destroy():void
		{
			if(_level1.parent != null)
			{
				_level1.parent.removeChild(_level1);	
			}
			if(_level2.parent != null)
			{
				_level2.parent.removeChild(_level2);	
			}
			if(_level3.parent != null)
			{
				_level3.parent.removeChild(_level3);	
			}
		}
	}
}