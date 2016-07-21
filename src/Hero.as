package
{
	import engine.Locator;
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class Hero extends Entity
	{
		public var graphic:MovieClip;	
		
		private var timerPunch:uint;
		private var timerKick:uint;
		private var timerDamage:uint;
		private var timerCrouchPunch:uint;
		private var timerCrouchKick:uint;
		
		public function Hero()
		{
			graphic = new MovieClip();
			graphic = Locator.assetManager.getMovieClip("Dino");
			
			Locator.inputManager.setRelation("Up", Keyboard.W);
			Locator.inputManager.setRelation("Down", Keyboard.S);
			Locator.inputManager.setRelation("Left", Keyboard.A);
			Locator.inputManager.setRelation("Right", Keyboard.D);
			Locator.inputManager.setRelation("Punch", Keyboard.J);
			Locator.inputManager.setRelation("Kick", Keyboard.K);	
		}
		
		override public function spawn(x:int, y:int):void
		{
			Locator.mainStage.addChild(graphic);
			graphic.x = x;
			graphic.y = y;
			graphic.scaleX = graphic.scaleY = C.GAME_SCALE;
			
			health = C.PLAYER_MAX_HEALTH;
			
			Locator.mainStage.addEventListener(KeyboardEvent.KEY_DOWN,keyDown);
			Locator.mainStage.addEventListener(KeyboardEvent.KEY_UP,keyUp);
		}
		
		public function update(xEnemy:int):void
		{
			animate();
			applyGravity();
			move(xEnemy);
			view(xEnemy);
		}
		
		private function keyDown(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.A:
					left = true;
					break;
				case Keyboard.D:
					right = true;
					break;
				case Keyboard.W:
					if(!isJumping && !isCrouching)
					{
						velocityY = C.PLAYER_JUMP_FORCE;
						isJumping = true;
						jumpingAnimation = true;
					}
					break;
				case Keyboard.S:
					if(!isJumping && !isCrouching)
					{
						isCrouching = true;
					}
					break;
				case Keyboard.J:
					if(!isJumping && punchEnable)
					{
						isPunching = true;
						punchEnable = false;
					}
					break;
				case Keyboard.K:
					if(!isJumping && kickEnable)
					{
						isKicking = true;
						kickEnable = false;
					}
					break;
			}	
		}
		
		private function keyUp(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.A:
					left = false;
					break;
				case Keyboard.D:
					right = false;
					break;
				case Keyboard.S:
					isCrouching = false;
					crouchAnimation = false;
					break;
				case Keyboard.J:
					punchEnable = true;
					break;
				case Keyboard.K:
					kickEnable = true;
					break;
			}
		}
		
		private function move(xEnemy:int):void
		{
			if (left && !isPunching && !isKicking && !isCrouching)
			{
				if (graphic.x <= 20)
				{
					graphic.x = 20;
				}
				else if (graphic.scaleX == -C.GAME_SCALE && graphic.x <= xEnemy + C.ENEMY_DISTANCE && !isJumping)
				{
					graphic.x = xEnemy + C.ENEMY_DISTANCE;	
				}
				else
				{
					graphic.x -= 	C.PLAYER_SPEED;	
				}
			}
			
			else if (right && !isPunching && !isKicking && !isCrouching)
			{
				if (graphic.x >= Locator.mainStage.stageWidth - 20)
				{
					graphic.x = Locator.mainStage.stageWidth - 20;
				}
				else if (graphic.scaleX == C.GAME_SCALE && graphic.x >= xEnemy - C.ENEMY_DISTANCE && !isJumping)
				{
					graphic.x = xEnemy - C.ENEMY_DISTANCE;
				}
				else
				{
					graphic.x += C.PLAYER_SPEED;	
				}
			}
		}
		
		private function applyGravity():void
		{
			velocityY -= C.GRAVITY;
			graphic.y -= velocityY;
			if(graphic.y >= floorY)
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
				
				timerPunch = setInterval(stopPunch, C.PUNCH_DELAY); // hacerlo con unlock...
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
				else if (!punchingAnimation && !kickingAnimation && !crouchAnimation)
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
			
			if (!left && !right && !isJumping && !isPunching && !isKicking && !isCrouching && !damageAnimation)
			{
				graphic.gotoAndPlay("idle");
				isWalking = false;
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
		
		public function destroy():void
		{
			if(graphic.parent != null)
			{
				Locator.mainStage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDown);
				Locator.mainStage.removeEventListener(KeyboardEvent.KEY_UP,keyUp);
				Locator.mainStage.removeChild(graphic);
				
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
			}
		}
	}
}