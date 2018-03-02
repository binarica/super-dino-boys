package
{
	import engine.Locator;
	import org.flashdevelop.utils.FlashConnect;
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class Hero extends Character
	{
		public var model:MovieClip;
		
		public var speed:Number = C.PLAYER_SPEED;
		public var health:int = C.PLAYER_MAX_HEALTH;
		
		private var timerPunch:uint;
		private var timerKick:uint;
		private var timerDamage:uint;
		private var timerCrouchPunch:uint;
		private var timerCrouchKick:uint;
		
		public var cheatCode:Array = [Keyboard.I, Keyboard.D, Keyboard.D, Keyboard.Q, Keyboard.D];
 		
		public function Hero()
		{
			model = new MovieClip();
			model = Locator.assetManager.getMovieClip("Dino");
			
			Locator.inputManager.setRelation("Left", Keyboard.A);
			Locator.inputManager.setRelation("Right", Keyboard.D);
			Locator.inputManager.setRelation("Up", Keyboard.W);
			Locator.inputManager.setRelation("Down", Keyboard.S);
			Locator.inputManager.setRelation("Punch", Keyboard.J);
			Locator.inputManager.setRelation("Kick", Keyboard.K);	
			
			Locator.console.registerCommand("flash", doubleSpeed, "Double speed.");
			Locator.console.registerCommand("moonwalk", moon, "No gravity.");
			Locator.console.registerCommand("givehealth", giveHealth, "Full health.");
		}
		
		public function doubleSpeed():void
		{
			speed *= 2;
			Locator.console.write("Double speed! Yee-haw!");
		}
		
		public function moon():void
		{
			gravity = C.GRAVITY / 2;
		}
		
		public function giveHealth():void
		{
			health = C.PLAYER_MAX_HEALTH;
			Locator.console.write("Restored to full health!");
		}
			
		override public function spawn(x:int, y:int):void
		{
			Locator.mainStage.addChild(model);
			model.x = x;
			model.y = y;
			model.scaleX = model.scaleY = C.GAME_SCALE;
		}
		
		public function update(xEnemy:int):void
		{
			animationControl();
			applyGravity();
			checkKeys();
			
			move(xEnemy);
			view(xEnemy);
		}
		
		private function checkKeys():void 
		{
			if(Locator.inputManager.compareSequence(cheatCode))
			{
				trace("Something something dark side");
			}
			
			left = Locator.inputManager.getKeyPressingByName("Left");
			right = Locator.inputManager.getKeyPressingByName("Right");
			
			if (Locator.inputManager.getKeyPressingByName("Up")) 
			{
				if (!isJumping && !isCrouching)
				{
					velocityY = C.PLAYER_JUMP_FORCE;
					isJumping = true;
					jumpingAnimation = true;
				}
			}
			
			if (Locator.inputManager.getKeyPressingByName("Down"))
			{
				if (!isJumping && !isCrouching)
				{
					isCrouching = true;
				}
			}
			else
			{
				isCrouching = false;
				crouchAnimation = false;
			}
			
			if (Locator.inputManager.getKeyPressingByName("Punch"))
			{
				if(!isJumping && punchEnable)
				{
					isPunching = true;
					punchEnable = false;
				}
			}
			else
			{
				punchEnable = true;
			}
			
			if (Locator.inputManager.getKeyPressingByName("Kick"))
			{
				if(!isJumping && kickEnable)
				{
					isKicking = true;
					kickEnable = false;
				}
			}
			else
			{
				kickEnable = true;
			}
		}
		
		private function move(xEnemy:int):void
		{
			if (left && !isPunching && !isKicking && !isCrouching)
			{
				if (model.x <= 20)
				{
					model.x = 20;
				}
				else if (model.scaleX == -C.GAME_SCALE && model.x <= xEnemy + C.ENEMY_DISTANCE && !isJumping)
				{
					model.x = xEnemy + C.ENEMY_DISTANCE;	
				}
				else
				{
					model.x -= 	speed;	
				}
			}
			
			else if (right && !isPunching && !isKicking && !isCrouching)
			{
				if (model.x >= Locator.mainStage.stageWidth - 20)
				{
					model.x = Locator.mainStage.stageWidth - 20;
				}
				else if (model.scaleX == C.GAME_SCALE && model.x >= xEnemy - C.ENEMY_DISTANCE && !isJumping)
				{
					model.x = xEnemy - C.ENEMY_DISTANCE;
				}
				else
				{
					model.x += speed;	
				}
			}
		}
		
		private function applyGravity():void
		{
			velocityY -= gravity;
			model.y -= velocityY;
			if(model.y >= floorY)
			{
				model.y = floorY;
				velocityY = 0;
				isJumping = false;
			}
		}
		
		private function animationControl():void
		{
			if ((left || right) && !isWalking && !isJumping && !punchingAnimation && !kickingAnimation && !isCrouching)
			{
				model.gotoAndPlay("walk");
				isWalking = true;
			}
			if (jumpingAnimation)
			{
				model.gotoAndPlay("jump");
				jumpingAnimation = false;
				isWalking = false;
			}
			if (isPunching && !punchingAnimation && !isJumping && !isCrouching)
			{
				model.gotoAndPlay("punch");
				punchingAnimation = true;
				isWalking = false;
				
				timerPunch = setInterval(stopPunch, C.PUNCH_DELAY); // hacerlo con unlock...
			}
			if (isKicking && !kickingAnimation && !isPunching && !isJumping && !isCrouching)
			{
				model.gotoAndPlay("kick");
				kickingAnimation = true;
				isWalking = false;
				
				timerKick = setInterval(stopKick, C.KICK_DELAY);
			}
			if (isCrouching)
			{
				if (isPunching && !punchingAnimation)
				{
					model.gotoAndPlay("crouch_punch");
					punchingAnimation = true;
					timerPunch = setInterval(stopPunch, C.PUNCH_DELAY);
				}
				else if (isKicking && !kickingAnimation)
				{
					model.gotoAndPlay("crouch_kick");
					kickingAnimation = true;
					timerKick = setInterval(stopKick, C.KICK_DELAY);
				}
				else if (!punchingAnimation && !kickingAnimation && !crouchAnimation)
				{
					model.gotoAndStop("crouch");
					crouchAnimation = true;
				}
				isWalking = false;
			}
			if (damage && !damageAnimation && !isJumping)
			{
				isCrouching ? model.gotoAndPlay("crouch_damage") : model.gotoAndPlay("standing_damage");
				
				damageAnimation = true;
				timerDamage = setInterval(stopDamage, 250);
			}
			
			if (!left && !right && !isJumping && !isPunching && !isKicking && !isCrouching && !damageAnimation)
			{
				model.gotoAndPlay("idle");
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
			if (model.x > x - 20 && model.scaleX != -C.GAME_SCALE)
			{
				model.scaleX = -C.GAME_SCALE;
				model.x += model.width/2;
			}
			else if (model.x <= x && model.scaleX != C.GAME_SCALE)
			{
				model.scaleX = C.GAME_SCALE;
				model.x -= model.width/2;
			}
		}
		
		override public function destroy():void
		{
			if (model.parent != null)
			{
				Locator.console.unregisterCommand("flash");
				Locator.console.unregisterCommand("moonwalk");
				Locator.console.unregisterCommand("givehealth");
				
				Locator.mainStage.removeChild(model);
				
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
				health = C.PLAYER_MAX_HEALTH;
			}
		}
	}
}