package
{
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	public class Behaviors
	{
		private var enemy:Enemy;
		private var player:Hero;
		
		private var moveTimer:uint = 0;
		private var hitTimer:uint = 0;
		private var hitTaken:Boolean = false;
		
		private var level:int = 1;
		
		public function Behaviors(enemy:Enemy, player: Hero)
		{
			this.enemy = enemy;
			this.player = player;
		}
		
		public function update():void
		{
			decision();
			stopCrouch();
			hitTimer++;
			moveTimer++;
		} 
		
		public function changeEnemy(newLevel:int):void
		{
			level = newLevel;
		}
		
		private function decision():void
		{	
			if (moveTimer >= 18 && Utils.random(1,10) <=6)
			{
				if (Utils.random(1,10) <= 5)
				{
					if (level == 2)
					{
						move(C.SAFE_RANGE + C.ATTACK_REACH);
					}
					else
					{
						move(C.SAFE_RANGE);	
					}	
					moveTimer = 0;	
				}
				else if (!enemy.isJumping)
				{
					if(level == 2)
					{
						move(C.ATTACK_RANGE + C.ATTACK_REACH);
					} 
					else
					{
						move(C.ATTACK_RANGE);	
					}
					moveTimer = 0;
				}
			}
			if (level == 2)
			{
				if ((enemy.enemyList[level-1].scaleX == -C.GAME_SCALE && player.model.x >= enemy.enemyList[level-1].x - C.ATTACK_RANGE - C.ATTACK_REACH) || (enemy.enemyList[level-1].scaleX == C.GAME_SCALE && player.model.x <= enemy.enemyList[level-1].x + C.ATTACK_RANGE + C.ATTACK_REACH))
				{
					if((player.isPunching || player.isKicking) && !enemy.isJumping)
					{
						attackResponse();	
					}	
					else if(!enemy.isJumping)
					{
						attack();
					}
				}	
			}
			else
			{
				if ((enemy.enemyList[level-1].scaleX == -C.GAME_SCALE && player.model.x >= enemy.enemyList[level-1].x - C.ATTACK_RANGE) || (enemy.enemyList[level-1].scaleX == C.GAME_SCALE && player.model.x <= enemy.enemyList[level-1].x + C.ATTACK_RANGE))
				{
					if((player.isPunching || player.isKicking) && !enemy.isJumping)
					{
						attackResponse();	
					}	
					else if(!enemy.isJumping)
					{
						attack();
					}
				}
			}
		}
		
		private function move(distance:int):void
		{
			if (player.model.x <= enemy.enemyList[level-1].x - distance)
			{
				enemy.left = true;
				enemy.right = false;
			}
			else if (player.model.x >= enemy.enemyList[level-1].x + distance)
			{
				enemy.right = true;
				enemy.left = false;
			}
			else
			{
				enemy.right = false;
				enemy.left = false;
			}
		}
		
		private function attackResponse():void
		{
			if(!player.isCrouching && !enemy.isCrouching && !hitTaken && !enemy.isJumping)
			{
				if (Utils.random(1,10) <= 5)
				{
					enemy.isCrouching = true;
					enemy.right = false;
					enemy.left = false;
					if (Utils.random(1,10) <= 4)
					{
						if (Utils.random(1,10) <= 4) enemy.isPunching = true;
						else enemy.isKicking = true;	
					}
					
				}
				else hitTaken = true;
			}
			else if (player.isCrouching && !hitTaken && !enemy.isJumping)
			{
				if (Utils.random(1,10) <= 5)
				{
					enemy.velocityY = C.ENEMY_JUMP_FORCE;
					enemy.isJumping = true;
					enemy.jumpingAnimation = true;
				}
				else hitTaken = true;
			}
		}
		
		private function attack():void
		{
			if (!enemy.isPunching && !enemy.isKicking && !enemy.isJumping && !enemy.isCrouching && Utils.random(1,10) <= 4 && hitTimer >= 24 && !player.isJumping)
			{
				if (Utils.random(1,10) <= 4)
				{
					enemy.isPunching = true;
				}
				else
				{
					enemy.isKicking = true;
				}
				hitTimer = 0;
			}
		}
		
		private function stopCrouch():void
		{
			if(!player.isPunching && !player.isKicking && !player.punchingAnimation && !player.kickingAnimation && !enemy.isJumping)
			{
				enemy.isCrouching = false;
				enemy.crouchAnimation = false;
				hitTaken = false;
			}
		}
	}
}