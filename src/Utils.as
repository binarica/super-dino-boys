package
{
	public class Utils
	{
		// Clamps number between two boundaries
		public static function clamp(val:Number, min:Number, max:Number):Number
		{
			if (min > val)
			{
				val = min;
			}
			else if (val > max)
			{
				val = max;
			}
			
			return val;
		}
		
		// Converts degrees to radians
		public static function radians(degrees:Number):Number
		{
			return degrees * (Math.PI / 180);
		}
		
		// Converts radians to degrees
		public static function degrees(radians:Number):Number
		{
			return radians * (180 / Math.PI);
		}
				
		// Gets length of right angled triangle
		public static function pythagoras(currentX:Number, currentY:Number, targetX:Number, targetY:Number):Number
		{
			return Math.sqrt(Math.pow(Math.abs(currentX - targetX), 2) + Math.pow(Math.abs(currentY - targetY), 2));
		}
		
		// Returns the angle between two X Y coordinates
		public static function coordAngle(currentX:Number, currentY:Number, targetX:Number, targetY:Number):Number
		{
			return Math.atan2(targetY - currentY, targetX - currentX);
		}
		
		// Returns 1 or -1 depending on sign of the number
		public static function sign(n:Number):int
		{
			if (n > 0)
			{
				return 1;
			}
			else if (n < 0)
			{
				return -1;
			}
			
			return 0;	
		}
		
		// Eases number towards target
		public static function ease(current:Number, target:Number, ease:Number):Number
		{
			return current + (target - current) * ease;
		}
		
		// Returns a random number
		public static function random(min:int, max:int):int
		{
			return Math.random() * (max-min) + min;
		}
	}
}