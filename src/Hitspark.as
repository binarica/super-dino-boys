package
{
	import engine.Locator;
	import flash.display.MovieClip;
	import flash.utils.setTimeout;
	
	public class Hitspark
	{		
		public var model:MovieClip;
		
		public function Hitspark()
		{
			model = new MovieClip();
			model = Locator.assetManager.getMovieClip("Hitspark");
		}
		
		public function spawn(posX:Number, posY:Number):void
		{
			Locator.mainStage.addChild(model);
			model.x = posX;
			model.y = posY;
			
			setTimeout(destroy, 100);
			//SceneGame.hitsparkList.push(this);
		}
		
		public function destroy():void 
		{	
			if (model.parent != null) 
			{
				model.parent.removeChild(model);
			}
			//SceneGame.hitsparkList.splice(SceneGame.hitsparkList.indexOf(this) , 1);
		}
	}
}