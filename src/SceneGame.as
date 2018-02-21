package
{
	import engine.CustomScene;
	import engine.Locator;
	
	import flash.display.MovieClip;
	import flash.utils.*;
	
	import org.bytearray.gif.player.GIFPlayer;

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
		
		private var hud:HUD = new HUD();
		private var restartTime:int;
		
		private var currentLevel:int = 1;
		
		private var ending:GIFPlayer = new GIFPlayer();
		
		public static var score:int = 0;
		public static var highscore:int = 0;
		
		public function SceneGame()
		{
			super("");
			
			ending = Locator.assetManager.getGIFImage("win");
			
			Locator.console.registerCommand("kill", kill, "Restart current level with original health.");
			Locator.console.registerCommand("reset", resetGame, "Reset the game.");
			Locator.console.registerCommand("loadlevel", loadLevel, "Go to level #.");
		}
		
		override public function enter():void
		{	
			currentLevel = 1;
			
			gameStarted = true;
			
			level.init(currentLevel);
			hud.init(currentLevel);
			
			enemy = new Enemy();
			enemy.spawn(C.ENEMY_START_X, C.ENEMY_START_Y);
			
			hero = new Hero();
			hero.spawn(C.PLAYER_START_X, C.PLAYER_START_Y);
			
			behaviors = new Behaviors(enemy,hero);
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
				enemy.update(hero.model.x);
				
				playerCollisionDetector();
				enemyCollisionDetector();
				behaviors.update();
				
				checkVictory();
				
				hud.update(hero.health, C.PLAYER_MAX_HEALTH, enemy.health, C.ENEMY_MAX_HEALTH);
			}
		}
		
		private function playerCollisionDetector():void
		{
			var code:String = heroCollisions.checkCollisionWithEnemy(hero, enemy, currentLevel);
			
			if ((hero.isPunching || hero.isKicking) && !heroHit && code!="Nothing")
			{
				switch (code)
				{
					case "UpperPunch":
						enemy.health -= C.HIGH_PUNCH_DAMAGE;
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
			var code:String = enemyCollisions.checkCollisionWithPlayer(enemy, hero, currentLevel);
			
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
				
				hero.model.gotoAndPlay("idle");
				hero.model.gotoAndPlay("death");
				
				if (hero.model.scaleX == C.GAME_SCALE)
				hero.model.x -= 30;
				else if (hero.model.scaleX == -C.GAME_SCALE) 
				hero.model.x += 30;
				
				Locator.soundManager.play(SoundID.PLAYER_DEATH, C.SOUND_FX_VOLUME, 0);
				enemy.enemyList[currentLevel-1].gotoAndPlay("idle");
				
				setTimeout(function():void {
					//Main.soundPlayer.Play(SoundManager.YOU_LOSE, C.SOUND_FX_VOLUME, 0); //"you lose!"
					Locator.soundManager.play(SoundID.YOU_LOSE, C.SOUND_FX_VOLUME, 0);				
					Locator.mainStage.addChild(finish);
					finish.gotoAndStop("Defeat");
					finish.x = Locator.mainStage.stageWidth / 2;
					finish.y = 200;
				}, 500);
		
				restartTime = setInterval(resetGame,4000);
			}
			
			else if (enemy.health <= 0)
			{
				gameStarted = false;
				
			hero.model.gotoAndPlay("idle");
				enemy.enemyList[currentLevel-1].gotoAndPlay("death");
				
				if (enemy.enemyList[currentLevel-1].scaleX == C.GAME_SCALE) 
					enemy.enemyList[currentLevel-1].x -= 30;
				else if (enemy.enemyList[currentLevel-1].scaleX == -C.GAME_SCALE) 
					enemy.enemyList[currentLevel-1].x += 30;
				
				if (currentLevel < 3)
				{
					Locator.mainStage.addChild(finish);
					finish.gotoAndStop("Victory");
					finish.x = Locator.mainStage.stageWidth / 2;
					finish.y = 200;
					
					Locator.soundManager.play(SoundID.YOU_WIN, C.SOUND_FX_VOLUME, 0);
					Locator.soundManager.play(SoundID.ENEMY_DEATH, C.SOUND_FX_VOLUME, 0);
					restartTime = setInterval(function():void {
						loadLevel(++currentLevel);
					}, 5000);
				}
				
				else
				{
					hud.destroy();
					
					Locator.soundManager.play(SoundID.BOSS_DEATH, C.SOUND_FX_VOLUME, 0);
					
					Locator.soundManager.stop(SoundID.FIGHTING);
					Locator.soundManager.play(SoundID.ENDING, C.ENV_VOLUME, 99999);
					
					setTimeout(function():void {
						Locator.mainStage.addChild(ending);
						ending.x = Locator.mainStage.stageWidth * 0.35;
						ending.y = 200;
					}, 2500);
					
					restartTime = setInterval(resetGame, 15000);
				}
			}
		}
		
		public function loadLevel(newLevel:int):void
		{
			clearInterval(restartTime);
			hero.destroy();
			hud.destroy();
			
			level.changeLevel(newLevel);
			enemy.changeEnemy(newLevel, C.ENEMY_START_X, C.ENEMY_START_Y);
			
			hero.spawn(C.PLAYER_START_X, C.PLAYER_START_Y);
			
			behaviors.changeEnemy(newLevel);
			hud.init(newLevel);
			
			if (finish.parent != null)
				finish.parent.removeChild(finish);
			
			gameStarted = true;
			
			if (Locator.console.isOpen)
				Locator.console.exit();
		}
		
		/*
		private function clearGame():void
		{
			clearInterval(restartTime);
			hero.destroy();
			enemy.destroy();
		}
		*/
		
		private function kill():void
		{
			loadLevel(currentLevel);
		}
		
		private function resetGame():void
		{
			if (Locator.console.isOpen)
				Locator.console.exit();
			
			changeScene("Menu");
		}
		
		override public function exit():void
		{			
			clearInterval(restartTime);
			
			hero.destroy();
			enemy.destroy();
			hud.destroy();
			level.destroy();
			
			if(finish.parent != null)
				finish.parent.removeChild(finish);
				
			Locator.mainStage.removeChild(ending);
			Locator.soundManager.stopAllSounds();
		}
	}
}