package engine 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	
	public class SoundManager
	{		
		private var sounds:Vector.<Sound> = new Vector.<Sound>();
		private var urls:Vector.<URLRequest> = new Vector.<URLRequest>();
		private var channels:Vector.<SoundChannel> = new Vector.<SoundChannel>();
		private var numSounds:int = 13;
		
		public function SoundManager()
		{
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/02 Jetpack Blues.mp3"));
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/03 Dawn Metropolis.mp3"));
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/07 Mermaid.mp3"));
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/bite.mp3"));
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/punch1.mp3"));
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/punch2.mp3"));
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/kick1.mp3"));
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/dog.mp3"));
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/scream.mp3"));
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/doom.mp3"));
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/you-win.mp3"));
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/you-lose.mp3"));
			urls.push(new URLRequest(C.ENGINE_PATH + "sounds/04 Planet.mp3"));
			
			for (var i:int = 0; i < urls.length; i++) 
			{
				var sample:Sound = new Sound();
				sample.load(urls[i]);
				sample.addEventListener(IOErrorEvent.IO_ERROR, loaderCheck);
				sounds.push(sample);
			}
			
			for (var j:int = 0; j < numSounds; j++) 
			{
				channels.push(new SoundChannel());
			}
			
		}
		
		public function play(id:int, vol:Number, loops:int):void
		{
			var config:SoundTransform = new SoundTransform();
			config.volume = vol;
			channels[id].stop();
			channels[id] = sounds[id].play(0, loops, config);
		}
		
		private function loaderCheck(e:Event):void
		{
			trace("Some sound files were not loaded.");
		}
		
		public function stop(id:int):void
		{
			channels[id].stop();
		}
		
		public function muteSound():void
		{
			SoundMixer.soundTransform = new SoundTransform(0);
		}
		
		public function unMuteSound():void
		{
			SoundMixer.soundTransform = new SoundTransform(1);
		}
		
		public function stopAllSounds():void
		{
			for each(var sc:SoundChannel in channels)
			{
				sc.stop();
			}	
		}
	}
}