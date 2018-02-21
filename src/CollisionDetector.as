package
{
	public class CollisionDetector
	{
		
		public function CollisionDetector()
		{
		}
		
		public function checkCollisionWithPlayer(enemy:Enemy, player:Hero, level:int):String
		{
			if(enemy.enemyList[level-1].getChildByName("Hand").hitTestObject(player.model.getChildByName("UpperBox")))
			{
				return "UpperPunch";
			}
			else if(enemy.enemyList[level-1].getChildByName("Hand").hitTestObject(player.model.getChildByName("LowerBox")))
			{
				return "LowerPunch";
			}
			else if(enemy.enemyList[level-1].getChildByName("Foot").hitTestObject(player.model.getChildByName("UpperBox")))
			{
				return "UpperKick";
			}
			else if(enemy.enemyList[level-1].getChildByName("Foot").hitTestObject(player.model.getChildByName("LowerBox")))
			{
				return "LowerKick";	
			}
			else
			{
				return "Nothing";
			}
		}
		
		public function checkCollisionWithEnemy(player:Hero, enemy:Enemy, level:int):String
		{
			if(player.model.getChildByName("Mano").hitTestObject(enemy.enemyList[level-1].getChildByName("UpperBox")))
			{
				return "UpperPunch";
			}
			else if(player.model.getChildByName("Mano").hitTestObject(enemy.enemyList[level-1].getChildByName("LowerBox")))
			{
				return "LowerPunch";
			}
			else if(player.model.getChildByName("Foot").hitTestObject(enemy.enemyList[level-1].getChildByName("UpperBox")))
			{
				return "UpperKick";
			}
			else if(player.model.getChildByName("Foot").hitTestObject(enemy.enemyList[level-1].getChildByName("LowerBox")))
			{
				return "LowerKick";	
			}
			else
			{
				return "Nothing";
			}
		}
	}
}