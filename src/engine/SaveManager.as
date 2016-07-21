package engine
{
	import flash.net.SharedObject;
	import flash.utils.Dictionary;

	public class SaveManager
	{
		public var saver:SharedObject;
		public var allData:Dictionary = new Dictionary();
		
		public function SaveManager()
		{
			trace("SaveManager OK");
		}
		
		public function save():void
		{
			saver = SharedObject.getLocal("SarasaTheGame", "/");
			saver.data.mySaves = allData;
			saver.flush();
			allData = new Dictionary();
		}
		
		public function load():void
		{
			saver = SharedObject.getLocal("SarasaTheGame", "/");
			
			allData = new Dictionary();
			for(var varName:String in saver.data.mySaves)
			{
				allData[varName] = saver.data.mySaves[varName];
			}
		}
	}
}