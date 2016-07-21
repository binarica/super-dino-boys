package
{
	import engine.CustomScene;
	import engine.Locator;
	
	import flash.display.MovieClip;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	public class SceneGame extends CustomScene
	{
		/*
		public static var PAUSED:String = "paused"; // For pause menu
		public static var PLAYING:String = "playing";// For playing state
		public static var START:String = "start";// For start menu
		public static var RESTART:String = "restart";// For restart menu
		public static var SILENT_RESTART:String = "silent_restart";// For restart without menu
		
		public static var currentState = "start";
		*/
		
		private var gameStarted:Boolean = false;
		
		private var level:Level = new Level();
		
		private var hero:Hero;
		private var enemy:Enemy;
		
		private var heroCollisions:CollisionDetector = new CollisionDetector();
		private var enemyCollisions:CollisionDetector = new CollisionDetector();
		
		private var heroHit:Boolean = false;
		private var enemyHit:Boolean = false;
		
		private var finish:MovieClip;
		
		private var behaviors:Behaviors;
		
		private var ui:UI = new UI();
		private var restartTime:int;
		
		private var currentLevel:int = 1;
		
		public static var score:int = 0;
		public static var highscore:int = 0;
		
		public function SceneGame()
		{
			super("");
		}
		
		override public function enter():void
		{	
			currentLevel = 1;
			
			gameStarted = true;
			
			level.init(currentLevel);
			ui.init(currentLevel);
			
			enemy = new Enemy();
			enemy.spawn(C.ENEMY_START_X, C.ENEMY_START_Y);
			
			hero = new Hero();
			hero.spawn(C.PLAYER_START_X, C.PLAYER_START_Y);
			
			behaviors = new Behaviors(enemy, hero);
			behaviors.changeEnemy(currentLevel);
			
			finish = new MovieClip();
			finish = Locator.assetManager.getMovieClip("Final");
			
			Locator.soundManager.play(SoundID.FIGHTING, C.ENV_VOLUME, 99999);
		}
		
		override public function update():void
		{
			if (gameStarted)
			{
				hero.update(enemy.enemyList[currentLevel-1].x);
				enemy.update(hero.graphic.x);
				
				playerCollisionDetector();
				enemyCollisionDetector();
				behaviors.update();
				
				checkVictory();
				
				ui.update(hero.health, C.PLAYER_MAX_HEALTH, enemy.health, C.ENEMY_MAX_HEALTH);
			}
		}
		
		private function playerCollisionDetector():void
		{
			var code:String = heroCollisions.checkCollisionWithEnemy(hero, enemy);
			
			if ((hero.isPunching || hero.isKicking) && !heroHit && code!="Nothing")
			{
				switch (code)
				{
					case "UpperPunch":
						enemy.health -= C.HIGH_PUNCH_DAMAGE; // reemplazar con takedamage, hacer la variable de health privada.
						Locator.soundManager.play(SoundID.PUNCH_HERO, C.SOUND_FX_VOLUME, 0);
						heroHit = true;
						break;
					case "LowerPunch":
						if(!enemy.isJumping)
						{
							enemy.health -= C.LOW_PUNCH_DAMAGE;
							Locator.soundManager.play(SoundID.PUNCH_HERO, C.SOUND_FX_VOLUME, 0);
							heroHit = true;	
						}
						break;
					case "UpperKick":
						enemy.health -= C.HIGH_KICK_DAMAGE;
						Locator.soundManager.play(SoundID.KICK_HERO, C.SOUND_FX_VOLUME, 0);
						heroHit = true;
						break;
					case "LowerKick":
						if(!enemy.isJumping)
						{
							enemy.health -= C.LOW_KICK_DAMAGE;
							Locator.soundManager.play(SoundID.KICK_HERO, C.SOUND_FX_VOLUME, 0);
							heroHit = true;	
						}
						break;
				}
				
				if(!enemy.isJumping) 
					enemy.damage = true;
			}
			if(heroHit && !hero.isPunching && !hero.isKicking)
			{
				heroHit = false;
			}
		}
		
		private function enemyCollisionDetector():void
		{
			var code:String = enemyCollisions.checkCollisionWithPlayer(enemy, hero);
			
			if((enemy.isPunching || enemy.isKicking) && !enemyHit && code!="Nothing")
			{
				switch(code)
				{
					case "UpperPunch":
						hero.health -= C.HIGH_PUNCH_DAMAGE;
						Locator.soundManager.play(SoundID.PUNCH_ENEMY, C.SOUND_FX_VOLUME, 0);
						enemyHit = true;
						break;
					case "LowerPunch":
						if(!hero.isJumping)
						{
							hero.health -= C.LOW_PUNCH_DAMAGE;
							Locator.soundManager.play(SoundID.PUNCH_ENEMY, C.SOUND_FX_VOLUME, 0);
							enemyHit = true;	
						}
						break;
					case "UpperKick":
						hero.health -= C.HIGH_KICK_DAMAGE;
						Locator.soundManager.play(SoundID.KICK_ENEMY, C.SOUND_FX_VOLUME, 0);
						enemyHit = true;
						break;
					case "LowerKick":
						if(!hero.isJumping)
						{
							hero.health -= C.LOW_KICK_DAMAGE;
							Locator.soundManager.play(SoundID.KICK_ENEMY, C.SOUND_FX_VOLUME, 0);
							enemyHit = true;	
						}
						break;
				}
				if(!hero.isJumping) hero.damage = true;
			}
			
			if(enemyHit && !enemy.isPunching && !enemy.isKicking)
			{
				enemyHit = false;
			}
		}
		
		private function checkVictory():void
		{
			if(hero.health <= 0)
			{
				gameStarted = false;
				
				hero.graphic.gotoAndPlay("idle");
				hero.graphic.gotoAndPlay("death");
				
				if (hero.graphic.scaleX == C.GAME_SCALE)
					hero.graphic.x -= 30;
				else if (hero.graphic.scaleX == -C.GAME_SCALE) 
					hero.graphic.x += 30;
				
				Locator.soundManager.play(SoundID.PLAYER_DEATH, C.SOUND_FX_VOLUME, 0);
				
				enemy.enemyList[currentLevel-1].gotoAndPlay("idle");
				
				Locator.mainStage.addChild(finish);
				finish.gotoAndStop("Defeat");
				finish.x = Locator.mainStage.stageWidth / 2;
				finish.y = 200;
				
				//Main.soundPlayer.Play(SoundManager.DEATH, C.SOUND_FX_VOLUME, 0); "you lose!"
				restartTime = setInterval(resetGame,4000);
			}
			
			else if (enemy.health <= 0)
			{
				gameStarted = false;
				
				hero.graphic.gotoAndPlay("idle");
				enemy.enemyList[currentLevel-1].gotoAndPlay("death");
				
				if (enemy.enemyList[currentLevel-1].scaleX == C.GAME_SCALE) 
					enemy.enemyList[currentLevel-1].x -= 30;
				else if (enemy.enemyList[currentLevel-1].scaleX == -C.GAME_SCALE) 
					enemy.enemyList[currentLevel-1].x += 30;
				
				Locator.mainStage.addChild(finish);
				finish.gotoAndStop("Victory");
				finish.x = Locator.mainStage.stageWidth / 2;
				finish.y = 200;
				
				if (currentLevel >= 3)
				{
					Locator.soundManager.play(SoundID.BOSS_DEATH, C.SOUND_FX_VOLUME, 0);
					restartTime = setInterval(resetGame, 10000);
				}
				else if (currentLevel < 3)
				{
					Locator.soundManager.play(SoundID.ENEMY_DEATH, C.SOUND_FX_VOLUME, 0);
					restartTime = setInterval(nextLevel, 5000);
				}
			}
		}
		
		private function nextLevel():void
		{
			clearInterval(restartTime);
			hero.destroy();
			ui.destroy();
			currentLevel++;
			
			level.changeLevel(currentLevel);
			enemy.changeEnemy(currentLevel, C.ENEMY_START_X, C.ENEMY_START_Y);
			
			hero.spawn(C.PLAYER_START_X, C.PLAYER_START_Y);
			
			behaviors.changeEnemy(currentLevel);
			ui.init(currentLevel);
			
			if (finish.parent != null)
				finish.parent.removeChild(finish);
			
			gameStarted = true;
		}
		
		private function resetGame():void
		{
			changeScene("Menu");
		}
		
		override public function exit():void
		{			
			clearInterval(restartTime);
			
			hero.destroy();
			enemy.destroy();
			ui.destroy();
			level.destroy();
			
			if(finish.parent != null)
				finish.parent.removeChild(finish);
			
			Locator.soundManager.stop(SoundID.FIGHTING);
		}
	}
}