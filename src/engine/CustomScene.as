package engine
{
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;

	[Event(name="enter", type="SceneEvent")]
	[Event(name="exit", type="SceneEvent")]
	[Event(name="change", type="SceneEvent")]
	
	public class CustomScene extends EventDispatcher
	{
		public var model:MovieClip;
		
		public function CustomScene(linkage:String)
		{
			if (linkage != null)
				model = Locator.assetManager.getMovieClip(linkage);
		}
		
		public function enter():void
		{
			Locator.sceneManager.screenContainer.addChild(model);
		}
		
		public function update():void
		{
			
		}
	
		public function exit():void
		{
			Locator.sceneManager.screenContainer.removeChild(model);
		}
		
		public function changeScene(name:String, params:Array = null):void
		{
			var e:SceneEvent = new SceneEvent(SceneEvent.CHANGE);
			e.params = params;
			e.targetScreen = name;
			
			dispatchEvent(e);
		}
	}
}