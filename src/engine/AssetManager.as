package engine
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import org.bytearray.gif.player.GIFPlayer;

	public class AssetManager extends EventDispatcher
	{
		public var loaderLinks:URLLoader;
		
		public var allAssets:Dictionary = new Dictionary();
		
		public var allLinksForLoad:Array = new Array();
		public var allNamesForLoad:Array = new Array();
		
		public var numAssetsLoaded:int = 0;
		public var numTotalAssets:int = 0;
		
		public var loaderMC:MCPreload = new MCPreload();
		
		public function AssetManager()
		{
			trace("AssetManager OK");
		}
		
		/** Carga el archivo que contiene los links. */
		public function loadLinks(path:String):void
		{
			var url:URLRequest = new URLRequest(C.ENGINE_PATH + path);
			loaderLinks = new URLLoader();
			loaderLinks.dataFormat = URLLoaderDataFormat.VARIABLES;
			loaderLinks.load(url);
			loaderLinks.addEventListener(Event.COMPLETE, evLinksComplete);
		}
		
		protected function evLinksComplete(event:Event):void
		{
			//trace("CONTENIDO: \n" + loaderLinks.data);
			//trace(escape(loaderLinks.data));
			//trace(loaderLinks.data.myLittleTank);
			
			for(var varName:String in loaderLinks.data)
			{
				//trace(varName, escape(loaderLinks.data[varName]));
				var linkCut:String = escape(loaderLinks.data[varName]).split("%0D%0A")[0];
				allLinksForLoad.push(linkCut);
				allNamesForLoad.push(varName);
			}
				
			//var linksCut:Array = escape(loaderLinks.data).split("%0D%0A");
			//urlTaskList = linksCut;
			
			//Seteo cuántos assets se van a cargar.
			numTotalAssets = allLinksForLoad.length;
			
			loadAsset( allLinksForLoad[0] );
			
			Locator.mainStage.addChild(loaderMC);
		}
		
		public function loadAsset(path:String):void
		{
			var folder:String = path.split("/")[0]; //El primer índice contiene SIEMPRE el nombre de la carpeta.
			var completeURL:String = C.ENGINE_PATH + path;
			
			switch (folder)
			{
				case "images":
				case "swfs":
					var newImage:Loader = new Loader();
					newImage.load(new URLRequest(completeURL));
					
					//El tipo de dato Loader tiene el addEventListener de carga completa dentro de la variable "contentLoaderInfo".
					newImage.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
					newImage.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, evError);
					newImage.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
					
					allAssets[ allNamesForLoad[0] ] = newImage;
					break;
				
				case "gifs":
					var newGIF:GIFPlayer = new GIFPlayer();
					newGIF.load(new URLRequest(completeURL));
					
					newGIF.addEventListener(IOErrorEvent.IO_ERROR, evError);
					newGIF.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
					newGIF.addEventListener(Event.COMPLETE, onCompleteHandler);					
					allAssets[ allNamesForLoad[0] ] = newGIF;
					break;				
				
				case "sounds":
					var newSound:Sound = new Sound();
					newSound.load(new URLRequest(completeURL));
					
					newSound.addEventListener(IOErrorEvent.IO_ERROR, evError);
					newSound.addEventListener(Event.COMPLETE, onCompleteHandler);
					allAssets[ allNamesForLoad[0] ] = newSound;
					break;
				
				case "text":
					var newTxt:URLLoader = new URLLoader();
					newTxt.load(new URLRequest(completeURL));
					
					newTxt.addEventListener(Event.COMPLETE, onCompleteHandler);
					allAssets[ allNamesForLoad[0] ] = newTxt;
					break;
			}
		}
		
		protected function evError(event:IOErrorEvent):void
		{
			trace("assets/images not found: " + event.target);
		}
		
		protected function onCompleteHandler(event:Event):void
		{
			numAssetsLoaded++;
			var percentTotal:int = numAssetsLoaded * 100 / numTotalAssets;
			loaderMC.mc_total.gotoAndStop(percentTotal);
			
			//Quito el evento del asset.
			event.currentTarget.removeEventListener(Event.COMPLETE, onCompleteHandler);
			
			allLinksForLoad.shift(); //Quito el primer elemento.
			allNamesForLoad.shift(); 
			
			if (allLinksForLoad.length > 0) //Pregunto si hay más archivos por cargar.
			{
				loadAsset(allLinksForLoad[0]);
			}
			else
			{
				Locator.mainStage.removeChild(loaderMC);
				dispatchEvent(new Event("all_assets_complete"));
			}
		}
		
		protected function onProgressHandler(event:ProgressEvent):void
		{
			var percent:int = event.bytesLoaded * 100 / event.bytesTotal;
			loaderMC.mc_current.gotoAndStop(percent);
		}
				
		public function getText(name:String):String
		{
			return allAssets[name] != null ? allAssets[ name ].data : null;
		}
		
		public function getSound(name:String):Sound
		{
			return allAssets[name];
		}
		
		public function getImage(name:String):Bitmap
		{
			var myLoader:Loader = allAssets[name];
			if (myLoader != null)
			{
				var bmpData:BitmapData = new BitmapData(myLoader.width, myLoader.height, true, 0x000000);
				bmpData.draw(myLoader);
				var bmpCopy:Bitmap = new Bitmap(bmpData);
				
				return bmpCopy;
			}
			
			return null;
		}
		
		public function getGIFImage(name:String):GIFPlayer
		{
			return allAssets[name];
		}
		
		public function getMovieClip(className:String):MovieClip
		{
			for (var varName:String in allAssets)
			{
				if (allAssets[varName] is Loader)
				{
					var myLoader:Loader = allAssets[varName];
					try
					{
						var myClass:Class = myLoader.contentLoaderInfo.applicationDomain.getDefinition(className) as Class;
						return new myClass();
					}
					catch (e1:ReferenceError)
					{
						trace("On Error Resume Next");
					}
				}
			}
			
			return null;
		}
	}
}