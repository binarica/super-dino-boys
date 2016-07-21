package
{
	public class CollisionDetector
	{
		
		public function CollisionDetector()
		{
		}
		
		public function checkCollisionWithPlayer(enemy:Enemy, hero:Hero):String // cambiar a entity!
		{
			if(enemy.graphic.getChildByName("Hand").hitTestObject(hero.graphic.getChildByName("UpperBox")))
			{
				return "UpperPunch";
			}
			else if(enemy.graphic.getChildByName("Hand").hitTestObject(hero.graphic.getChildByName("LowerBox")))
			{
				return "LowerPunch";
			}
			else if(enemy.graphic.getChildByName("Foot").hitTestObject(hero.graphic.getChildByName("UpperBox")))
			{
				return "UpperKick";
			}
			else if(enemy.graphic.getChildByName("Foot").hitTestObject(hero.graphic.getChildByName("LowerBox")))
			{
				return "LowerKick";	
			}
			else
			{
				return "Nothing";
			}
		}
		
		public function checkCollisionWithEnemy(hero:Hero, enemy:Enemy):String
		{
			if(hero.graphic.getChildByName("Mano").hitTestObject(enemy.graphic.getChildByName("UpperBox")))
			{
				return "UpperPunch";
			}
			else if(hero.graphic.getChildByName("Mano").hitTestObject(enemy.graphic.getChildByName("LowerBox")))
			{
				return "LowerPunch";
			}
			else if(hero.graphic.getChildByName("Foot").hitTestObject(enemy.graphic.getChildByName("UpperBox")))
			{
				return "UpperKick";
			}
			else if(hero.graphic.getChildByName("Foot").hitTestObject(enemy.graphic.getChildByName("LowerBox")))
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