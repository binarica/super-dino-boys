package
{
	public class Character
	{
		public var velocityY:int = 0;
		public var floorY:int = 800;
		
		public var left:Boolean = false;
		public var right:Boolean = false;
		
		public var isJumping:Boolean = false;
		public var isCrouching:Boolean = false;
		public var isWalking:Boolean = false;
		public var isPunching:Boolean = false;
		public var isKicking:Boolean = false;
		
		public var crouchAnimation:Boolean = false;
		public var jumpingAnimation:Boolean = false;
		public var punchingAnimation:Boolean = false;
		
		public var kickingAnimation:Boolean = false;
		public var punchEnable:Boolean = true;
		public var kickEnable:Boolean = true;
		public var damage:Boolean = false;
		public var damageAnimation:Boolean = false;
		
		public function Character()
		{
			
		}
		
		public function spawn(x:int, y:int):void
		{

		}
		
		public function destroy():void
		{

		}
		
	}
}