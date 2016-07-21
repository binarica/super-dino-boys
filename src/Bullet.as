package
{	
	import flash.display.MovieClip;
	
	public class Bullet
	{		
		public var model:MovieClip;
		public var speed:Number;
		public var targetX:Number;
		public var targetY:Number;
		public var distanceX:Number;
		public var distanceY:Number;
		public var radians:Number;
		public var degrees:Number;
		
		public function Bullet(posX:Number, posY:Number, targetX:Number, targetY:Number)
		{
			/*
			model = Locator.assetsManager.getMovieClip("MCBullet");
			Locator.mainStage.addChild(model);
			*/
			
			model.x = posX;
			model.y = posY;
			this.targetX = targetX;
			this.targetY = targetY;
			this.speed = C.BULLET_SPEED;
		}
		
		public function update()
		{
			distanceX = targetX - model.x;
			distanceY = targetY - model.y;
			
			/*distanceX = Locator.mainStage.mouseX - model.x;
			distanceY = Locator.mainStage.mouseY - model.y;*/
			
			radians = Math.atan2(distanceY, distanceX);
			degrees = radians * 180 / Math.PI;
			
			model.rotation = degrees;
			
			if (Math.abs(distanceX) > speed && Math.abs(distanceY) > speed)
			{
				model.x += Math.cos(radians) * speed;
				model.y += Math.sin(radians) * speed;
			}
		}
		
		public function notInScreen():Boolean
		{
			// return (model.x > C.GAME_WIDTH);
		}
	}
}