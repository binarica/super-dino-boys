package
{
	import engine.CustomScene;
	import engine.Locator;
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.*;
		
	import org.bytearray.gif.player.GIFPlayer;

	public class SceneGame extends CustomScene
	{
		public static var PAUSED:String = "paused";			// For pause menu
		public static var PLAYING:String = "playing";		// For playing state
		public static var START:String = "start";			// For start menu
		public static var RESTART:String = "restart";		// For restart menu
		public static var STAGE_END:String = "stage end";
		
		public static var currentState:String = "start";
		
		private var level:Level = new Level();
		
		private var hero:Hero;
		private var enemy:Enemy;
		
		private var heroCollisions:CollisionDetector = new CollisionDetector();
		private var enemyCollisions:CollisionDetector = new CollisionDetector();
		
		private var heroHit:Boolean = false;
		private var enemyHit:Boolean = false;
		
		private var win:MovieClip;
		private var lose:MovieClip;
		
		private var behaviors:Behaviors;
		
		private var hud:HUD = new HUD();
		private var restartTime:int;
		
		private var hitStopFPS:Number = 0;
		
		private var currentLevel:int = 1;
		
		private var ending:GIFPlayer;
		
		public static var score:int = 0;
		public static var highscore:int = 0;
		
		public function SceneGame()
		{
			super("");
				
			Locator.inputManager.setRelation("Pause", Keyboard.P);
			
			Locator.console.registerCommand("mute", mute, "Mute sound.");
			Locator.console.registerCommand("kill", kill, "Restart current level with original health.");
			Locator.console.registerCommand("reset", resetGame, "Reset the game.");
			Locator.console.registerCommand("loadlevel", loadLevel, "Go to level #.");
			Locator.console.registerCommand("armageddon", suddenDeath, "Sudden death.");
		}
		
		override public function enter():void
		{	
			currentLevel = 1;
			currentState = PLAYING;
			
			level.init(currentLevel);
			hud.init(currentLevel);
			
			enemy = new Enemy();
			enemy.spawn(C.ENEMY_START_X, C.ENEMY_START_Y);
			
			hero = new Hero();
			hero.spawn(C.PLAYER_START_X, C.PLAYER_START_Y);
			
			behaviors = new Behaviors(enemy,hero);
			behaviors.changeEnemy(currentLevel);
						
			win = new MovieClip();
			win = Locator.assetManager.getMovieClip("YouWin");

			lose = new MovieClip();
			lose = Locator.assetManager.getMovieClip("YouLose");
			
			ending = new GIFPlayer();
			ending = Locator.assetManager.getGIFImage("end");
			
			Locator.soundManager.play(SoundID.FIGHTING, C.ENV_VOLUME, 99999);
		}
		
		override public function update():void
		{
			switch (currentState)
			{
				case PLAYING:
					if (Locator.console.isOpen) 
					{
						currentState = PAUSED;
					}
					
					hero.update(enemy.enemyList[currentLevel - 1].x);
					enemy.update(hero.model.x);
					hud.update(hero.health, C.PLAYER_MAX_HEALTH, enemy.health, C.ENEMY_MAX_HEALTH);
					
					playerCollisionDetector();
					enemyCollisionDetector();
					
					behaviors.update();
					
					checkVictory();
					break;
							
				case PAUSED:
					if (!Locator.console.isOpen) 
					{
						currentState = PLAYING;
					}

					hero.model.stop();
					enemy.enemyList[currentLevel - 1].stop();

					break;
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
				
				if (!enemy.isJumping)
				{
					enemy.damage = true;
				}
			}
			
			if(heroHit && !hero.isPunching && !hero.isKicking)
			{
				/*
				var h:Hitspark = new Hitspark();
				h.spawn(hero.model.x, hero.model.y);
				*/
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
				
				if (!hero.isJumping) 
				{
					hero.damage = true;
				}
			}
			
			if(enemyHit && !enemy.isPunching && !enemy.isKicking)
			{
				/*
				var h:Hitspark = new Hitspark();
				h.spawn(enemy[currentLevel - 1].x, enemy[currentLevel - 1].y);	
				*/
				enemyHit = false;
			}
		}
						
		private function checkVictory():void
		{
			if (hero.health <= 0)
			{
				currentState = STAGE_END;
				
				enemy.enemyList[currentLevel-1].gotoAndPlay("idle");
				hero.model.gotoAndPlay("idle");
				hero.model.gotoAndPlay("death");
				
				if (hero.model.scaleX == C.GAME_SCALE)
				hero.model.x -= 30;
				else if (hero.model.scaleX == -C.GAME_SCALE) 
				hero.model.x += 30;
				
				Locator.mainStage.addChild(lose);
				lose.x = Locator.mainStage.stageWidth / 2;
				lose.y = 220;
				
				Locator.soundManager.play(SoundID.YOU_LOSE, C.SOUND_FX_VOLUME, 0);	
				Locator.soundManager.play(SoundID.PLAYER_DEATH, C.SOUND_FX_VOLUME, 0);
				
				restartTime = setInterval(resetGame, 4000);
			}
			else if (enemy.health <= 0)
			{
				currentState = STAGE_END;
				
				hero.model.gotoAndPlay("idle");
				enemy.enemyList[currentLevel-1].gotoAndPlay("death");
				
				if (enemy.enemyList[currentLevel-1].scaleX == C.GAME_SCALE) 
					enemy.enemyList[currentLevel-1].x -= 30;
				else if (enemy.enemyList[currentLevel-1].scaleX == -C.GAME_SCALE) 
					enemy.enemyList[currentLevel-1].x += 30;
				
				if (currentLevel < 3)
				{
					Locator.mainStage.addChild(win);
					win.x = Locator.mainStage.stageWidth / 2;
					win.y = 200;
					
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
					
					restartTime = setInterval(resetGame, 10000);
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
			
			if (win.parent != null) 
			{	
				win.parent.removeChild(win);
			}
			
			if (lose.parent != null) 
			{	
				lose.parent.removeChild(lose);
			}
			
			if (Locator.console.isOpen) 
			{	
				Locator.console.exit();
			}
				
			currentState = PLAYING;
		}
		
		public function suddenDeath():void
		{
			hero.health = 1;
			enemy.health = 1;
		}
		
		/*
		private function clearGame():void
		{
			clearInterval(restartTime);
			hero.destroy();
			enemy.destroy();
		}
		*/
				
		private function keyUp(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.P:
					currentState = PLAYING;
					break;
			}
		}
		
		public function mute(status:String):void
		{
			if (status == "on")
				Locator.soundManager.muteSound();
			else if(status == "off")
				Locator.soundManager.unMuteSound();	
			else
				Locator.console.write("Missing parameter");
		}
		
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
			
			Locator.console.unregisterCommand("mute");
			Locator.console.unregisterCommand("kill");
			Locator.console.unregisterCommand("reset");
			Locator.console.unregisterCommand("loadlevel");
			Locator.console.unregisterCommand("armageddon");
			
			hero.destroy();
			enemy.destroy();
			hud.destroy();
			level.destroy();
					
			if (win.parent != null) 
			{	
				win.parent.removeChild(win);
			}
			
			if (lose.parent != null) 
			{	
				lose.parent.removeChild(lose);
			}
			
			if (ending.parent != null) 
			{
				ending.parent.removeChild(ending);
			}
			
			Locator.soundManager.stopAllSounds();
		}
	}
}