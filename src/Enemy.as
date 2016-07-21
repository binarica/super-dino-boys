package
{
	import engine.Locator;
	
	import flash.display.MovieClip;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class Enemy extends Entity
	{
		public var graphic:MovieClip;	
		
		public var enemyList:Array = new Array();
		
		/* 
		usá un diccionario, cambiá el enemigo actual con un string:
		public var enemyList:Dictionary = new Dictionary();
		private var enemyName:String;
		
		o con un array:
		public static const enemyNames:Array = new Array("lev1","lev2","lev3");
		*/

		private var timerPunch:uint;
		private var timerKick:uint;
		private var timerDamage:uint;
		
		private var currentLevel:int = 1;
		
		public function Enemy()
		{		
			graphic = new MovieClip();
			
			enemyList.push(Locator.assetManager.getMovieClip("Rumble"));
			enemyList.push(Locator.assetManager.getMovieClip("Robot"));
			enemyList.push(Locator.assetManager.getMovieClip("Alien"));
		}
		
		override public function spawn(x:int, y:int):void
		{
			graphic = enemyList[currentLevel-1];
			Locator.mainStage.addChild(graphic);
			
			graphic.x = x;
			graphic.y = y;
			graphic.scaleX = graphic.scaleY = C.GAME_SCALE;
			
			health = C.ENEMY_MAX_HEALTH;
		}
		
		public function update(xHero:Number):void
		{
			animate();
			applyGravity();
			move(xHero);
			view(xHero);
		}
		
		private function move(xHero:Number):void
		{
			if (left && !isPunching && !isKicking && !isCrouching)
			{
				if (graphic.x <= 130)
				{
					graphic.x = 130;
				}
				else if (graphic.scaleX == -3 && graphic.x <= xHero + C.ENEMY_DISTANCE && !isJumping)
				{
					graphic.x = xHero + C.ENEMY_DISTANCE;
				}
				else
				{
					graphic.x -= C.ENEMY_SPEED;	
				}
			}
			else if(right && !isPunching && !isKicking && !isCrouching)
			{
				if (graphic.x >= Locator.mainStage.stageWidth - 130)
				{
					graphic.x = Locator.mainStage.stageWidth - 130;
				}
				else if (graphic.scaleX == 3 && graphic.x >= xHero -C.ENEMY_DISTANCE && !isJumping)
				{
					graphic.x = xHero - C.ENEMY_DISTANCE;
				}
				else
				{
					graphic.x += C.ENEMY_SPEED;	
				}
			}
		}
		
		private function applyGravity():void
		{
			velocityY -= C.GRAVITY;
			graphic.y -= velocityY;
			if (graphic.y >= floorY)
			{
				graphic.y = floorY;
				velocityY = 0;
				isJumping = false;
			}
		}
		
		private function animate():void
		{
			if ((left || right) && !isWalking && !isJumping && !punchingAnimation && !kickingAnimation && !isCrouching)
			{
				graphic.gotoAndPlay("walk");
				isWalking = true;
			}
			if (!left && !right && !isJumping && !isPunching && !isKicking && !isCrouching && !damageAnimation)
			{
				graphic.gotoAndPlay("idle");
				isWalking = false;
			}
			if (jumpingAnimation)
			{
				graphic.gotoAndPlay("jump");
				jumpingAnimation = false;
				isWalking = false;
			}
			if (isPunching && !punchingAnimation && !isJumping && !isCrouching)
			{
				graphic.gotoAndPlay("punch");
				punchingAnimation = true;
				isWalking = false;
				timerPunch = setInterval(stopPunch, C.PUNCH_DELAY);
			}
			if (isKicking && !kickingAnimation && !isPunching && !isJumping && !isCrouching)
			{
				graphic.gotoAndPlay("kick");
				kickingAnimation = true;
				isWalking = false;
				timerKick = setInterval(stopKick, C.KICK_DELAY);
			}
			if (isCrouching)
			{
				if (isPunching && !punchingAnimation)
				{
					graphic.gotoAndPlay("crouch_punch");
					punchingAnimation = true;
					timerPunch = setInterval(stopPunch, C.PUNCH_DELAY);
				}
				else if (isKicking && !kickingAnimation)
				{
					graphic.gotoAndPlay("crouch_kick");
					kickingAnimation = true;
					timerKick = setInterval(stopKick, C.KICK_DELAY);
				}
				else if (!punchingAnimation && !kickingAnimation && !crouchAnimation && !isJumping)
				{
					graphic.gotoAndStop("crouch");
					crouchAnimation = true;
				}
				isWalking = false;
			}
			if (damage && !damageAnimation && !isJumping)
			{
				if (!isCrouching)	
					graphic.gotoAndPlay("standing_damage");
				else 
					graphic.gotoAndPlay("crouch_damage");
				
				damageAnimation = true;
				timerDamage = setInterval(stopDamage, 250);
			}
		}
		
		private function stopPunch():void
		{
			isPunching = false;
			punchingAnimation = false;
			clearInterval(timerPunch);
		}
		
		private function stopKick():void
		{
			isKicking = false;
			kickingAnimation = false;
			clearInterval(timerKick);
		}
		
		private function stopDamage():void
		{
			damage = false;
			damageAnimation = false;
			clearInterval(timerDamage);
		}
		
		public function view(x:int):void
		{
			if (graphic.x > x - 20 && graphic.scaleX != -C.GAME_SCALE)
			{
				graphic.scaleX = -C.GAME_SCALE;
				graphic.x += graphic.width/2;
			}
			else if (graphic.x <= x && graphic.scaleX != C.GAME_SCALE)
			{
				graphic.scaleX = C.GAME_SCALE;
				graphic.x -= graphic.width/2;
			}
		}
		
		public function changeEnemy(nextLevel:int, x:int, y:int):void
		{			
			if(graphic.parent != null)
			{
				graphic.parent.removeChild(graphic);
			}
			
			currentLevel = nextLevel;
			spawn(x, y);
			
			left = false;
			right = false;
			isCrouching = false;
			crouchAnimation = false;
			isWalking = false;
			isJumping = false;
			jumpingAnimation = false;
			isPunching = false;
			punchingAnimation = false;
			isKicking = false;
			kickingAnimation = false;
			punchEnable = true;
			kickEnable = true;
			damage = false;
			damageAnimation = false;
			//speed = 20; por si queremos cambiar la velocidad a otros enemigos...
			velocityY = 0;
		}
		
		public function destroy():void
		{
			for (var i:int = 0; i < enemyList.length; i++) 
			{
				if(enemyList[i].parent != null) enemyList[i].parent.removeChild(enemyList[i]);
			}
			
			left = false;
			right = false;
			isCrouching = false;
			crouchAnimation = false;
			isWalking = false;
			isJumping = false;
			jumpingAnimation = false;
			isPunching = false;
			punchingAnimation = false;
			isKicking = false;
			kickingAnimation = false;
			punchEnable = true;
			kickEnable = true;
			damage = false;
			damageAnimation = false;
			velocityY = 0;
			currentLevel = 1;
		}
	}
}