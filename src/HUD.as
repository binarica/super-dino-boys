package
{
	import engine.Locator;
	
	import flash.display.MovieClip;

	public class HUD
	{
		private var playerBar:MovieClip;
		private var enemyBars:Array = new Array();
		
		private var level:int = 1;
		
		public function HUD()
		{
			playerBar = new MovieClip();
			playerBar = Locator.assetManager.getMovieClip("DinoBar");
				
			enemyBars.push(Locator.assetManager.getMovieClip("RumbleBar"));
			enemyBars.push(Locator.assetManager.getMovieClip("RobotBar"));
			enemyBars.push(Locator.assetManager.getMovieClip("AlienBar"));
		}
		
		public function init(nextLevel:int):void
		{
			if (level != nextLevel) 
				level = nextLevel;
			
			Locator.mainStage.addChild(playerBar);
			
			playerBar.gotoAndStop(100);
			playerBar.x = 50;
			playerBar.y = 50;
			
			Locator.mainStage.addChild(enemyBars[level-1]);
			enemyBars[level-1].gotoAndStop(100);
			enemyBars[level-1].x = 755;
			enemyBars[level-1].y = 50;
		}
		
		public function update(ryuLife:int, ryuMax:int, enemyLife:int, kenMax:int):void
		{
			var perc:int = (ryuLife * 100) / ryuMax;
			playerBar.gotoAndStop(perc);
			
			perc = (enemyLife * 100) / kenMax;
			enemyBars[level-1].gotoAndStop(perc);
		}
		
		public function destroy():void
		{
			 if (playerBar.parent != null)
			 {
				playerBar.parent.removeChild(playerBar);
			 }
			 for (var i:int = 0; i < enemyBars.length; i++) 
			 {
				 if (enemyBars[i].parent != null) 
					 enemyBars[i].parent.removeChild(enemyBars[i]);
			 }
			 
		}
	}
}