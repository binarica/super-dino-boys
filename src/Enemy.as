package
{
	import engine.Locator;
	
	import flash.display.MovieClip;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class Enemy extends Character
	{
		public var enemyList:Array = new Array();
		
		/* 
		usá un diccionario, cambiá el enemigo actual con un string:
		public var enemyList:Dictionary = new Dictionary();
		private var enemyName:String;
		*/
		
		//o con un array:
		//public static const enemyNames:Array = new Array("lev1","lev2","lev3");
		
		public var health:int = C.ENEMY_MAX_HEALTH;
		private var timerPunch:uint;
		private var timerKick:uint;
		private var timerDamage:uint;
		
		private var currentLevel:int = 1;
		
		public function Enemy()
		{		
			enemyList.push(Locator.assetManager.getMovieClip("Rumble"));
			enemyList.push(Locator.assetManager.getMovieClip("Robot"));
			enemyList.push(Locator.assetManager.getMovieClip("Alien"));
		}
		
		override public function spawn(x:int, y:int):void
		{
			Locator.mainStage.addChild(enemyList[currentLevel-1]);
			
			enemyList[currentLevel-1].x = x;
			enemyList[currentLevel-1].y = y;
			enemyList[currentLevel-1].scaleX = enemyList[currentLevel-1].scaleY = C.GAME_SCALE;
		}
		
		public function update(xHero:Number):void
		{
			animationControl();
			applyGravity();
			move(xHero);
			lookAt(xHero);
		}
		
		private function move(xHero:Number):void
		{
			if (left && !isPunching && !isKicking && !isCrouching)
			{
				if (enemyList[currentLevel-1].x <= 130)
				{
					enemyList[currentLevel-1].x = 130;
				}
				else if (enemyList[currentLevel-1].scaleX == -3 && enemyList[currentLevel-1].x <= xHero + C.ENEMY_DISTANCE && !isJumping)
				{
					enemyList[currentLevel-1].x = xHero + C.ENEMY_DISTANCE;
				}
				else
				{
					enemyList[currentLevel-1].x -= C.ENEMY_SPEED;	
				}
			}
			else if(right && !isPunching && !isKicking && !isCrouching)
			{
				if (enemyList[currentLevel-1].x >= Locator.mainStage.stageWidth - 130)
				{
					enemyList[currentLevel-1].x = Locator.mainStage.stageWidth - 130;
				}
				else if (enemyList[currentLevel-1].scaleX == 3 && enemyList[currentLevel-1].x >= xHero -C.ENEMY_DISTANCE && !isJumping)
				{
					enemyList[currentLevel-1].x = xHero - C.ENEMY_DISTANCE;
				}
				else
				{
					enemyList[currentLevel-1].x += C.ENEMY_SPEED;	
				}
			}
		}
		
		private function applyGravity():void
		{
			velocityY -= gravity;
			enemyList[currentLevel-1].y -= velocityY;
			if (enemyList[currentLevel-1].y >= floorY)
			{
				enemyList[currentLevel-1].y = floorY;
				velocityY = 0;
				isJumping = false;
			}
		}
		
		private function animationControl():void
		{
			if ((left || right) && !isWalking && !isJumping && !punchingAnimation && !kickingAnimation && !isCrouching)
			{
				enemyList[currentLevel-1].gotoAndPlay("walk");
				isWalking = true;
			}
			if (!left && !right && !isJumping && !isPunching && !isKicking && !isCrouching && !damageAnimation)
			{
				enemyList[currentLevel-1].gotoAndPlay("idle");
				isWalking = false;
			}
			if (jumpingAnimation)
			{
				enemyList[currentLevel-1].gotoAndPlay("jump");
				jumpingAnimation = false;
				isWalking = false;
			}
			if (isPunching && !punchingAnimation && !isJumping && !isCrouching)
			{
				enemyList[currentLevel-1].gotoAndPlay("punch");
				punchingAnimation = true;
				isWalking = false;
				timerPunch = setInterval(stopPunch, C.PUNCH_DELAY);
			}
			if (isKicking && !kickingAnimation && !isPunching && !isJumping && !isCrouching)
			{
				enemyList[currentLevel-1].gotoAndPlay("kick");
				kickingAnimation = true;
				isWalking = false;
				timerKick = setInterval(stopKick, C.KICK_DELAY);
			}
			if (isCrouching)
			{
				if (isPunching && !punchingAnimation)
				{
					enemyList[currentLevel-1].gotoAndPlay("crouch_punch");
					punchingAnimation = true;
					timerPunch = setInterval(stopPunch, C.PUNCH_DELAY);
				}
				else if (isKicking && !kickingAnimation)
				{
					enemyList[currentLevel-1].gotoAndPlay("crouch_kick");
					kickingAnimation = true;
					timerKick = setInterval(stopKick, C.KICK_DELAY);
				}
				else if (!punchingAnimation && !kickingAnimation && !crouchAnimation && !isJumping)
				{
					enemyList[currentLevel-1].gotoAndStop("crouch");
					crouchAnimation = true;
				}
				isWalking = false;
			}
			if (damage && !damageAnimation && !isJumping)
			{
				if (!isCrouching)	
					enemyList[currentLevel-1].gotoAndPlay("standing_damage");
				else 
					enemyList[currentLevel-1].gotoAndPlay("crouch_damage");
				
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
		
		public function lookAt(x:int):void
		{
			if (enemyList[currentLevel-1].x > x - 20 && enemyList[currentLevel-1].scaleX != -C.GAME_SCALE)
			{
				enemyList[currentLevel-1].scaleX = -C.GAME_SCALE;
				enemyList[currentLevel-1].x += enemyList[currentLevel-1].width/2;
			}
			else if (enemyList[currentLevel-1].x <= x && enemyList[currentLevel-1].scaleX != C.GAME_SCALE)
			{
				enemyList[currentLevel-1].scaleX = C.GAME_SCALE;
				enemyList[currentLevel-1].x -= enemyList[currentLevel-1].width/2;
			}
		}
		
		public function changeEnemy(nextLevel:int, x:int, y:int):void
		{
			if(enemyList[nextLevel-2].parent != null)
			{
				enemyList[nextLevel-2].parent.removeChild(enemyList[nextLevel-2]);
			}
			
			currentLevel = nextLevel;
			Locator.mainStage.addChild(enemyList[currentLevel-1]);
			enemyList[currentLevel-1].x = x;
			enemyList[currentLevel-1].y = y;
			enemyList[currentLevel-1].scaleX = enemyList[currentLevel-1].scaleY = C.GAME_SCALE;
			
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
			damage = false;
			damageAnimation = false;
			punchEnable = true;
			kickEnable = true;
			//speed = 20; por si queremos cambiar la velocidad a otros enemigos...
			velocityY = 0;
			health = C.ENEMY_MAX_HEALTH;
		}
		
		override public function destroy():void
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
			health = C.ENEMY_MAX_HEALTH;
			currentLevel = 1;
		}
	}
}