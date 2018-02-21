package engine
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	public class Console
	{
		public var container:Sprite = new Sprite();
		
		public var mc:MCConsole;
		
		public var console_log:TextField;
		public var console_input:TextField;
		public var console_format:TextFormat;
		
		public var isOpen:Boolean;
		public var allCommands:Dictionary = new Dictionary();
		
		public function Console()
		{
			trace("Console OK");
		
			console_format = new TextFormat("Comic Sans MS", 24, 0x0033FF);
			
			console_log = new TextField();
			console_log.x = 100;
			console_log.y = 100;
			console_log.defaultTextFormat = console_format;
			console_log.width = C.GAME_WIDTH;
			console_log.height = C.GAME_HEIGHT * 0.75;
			
			console_input = new TextField();
			console_input.x = 100;
			console_input.y = 800;
			console_input.defaultTextFormat = console_format;
			console_input.width = C.GAME_WIDTH;
			console_input.height = C.GAME_HEIGHT * 0.25;
			console_input.type = TextFieldType.INPUT;
	
			mc = new MCConsole();
			Locator.mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			registerCommand("cls", clear, "Clears the terminal screen.");
			registerCommand("help", help, "Give the user much needed help.");
			registerCommand("exit", exit, "Exits the console.");
			registerCommand("quit", quit, "Go back to your boring life.");
			
			container.addChild(mc);
			container.addChild(console_log);
			container.addChild(console_input);
		}
		
		public function exit():void
		{
			clear();
			close();
			isOpen = false;
		}

		public function quit():void
		{
			NativeApplication.nativeApplication.exit(0);
		}
		
		/** Registra un comando en la consola.
		 * 
		 * @param name Nombre del comando.
		 * @param command Comando a ejecutar.
		 * @param description Descripción del comando. */
		
		public function registerCommand(name:String, command:Function, description:String="No description"):void
		{
			var cData:CommandData = new CommandData();
			cData.name = name;
			cData.command = command;
			cData.description = description;
			
			allCommands[name] = cData;
		}
		
		public function unregisterCommand(name:String):void
		{
			delete allCommands[name];
		}
		
		public function help():void
		{
			clear();
			
			for each(var cData:CommandData in allCommands)
			{
				write(cData.name + ": " + cData.description);
			}
		}
		
		public function clear():void
		{
			console_log.text = "";
		}
		
		public function execCommand():void
		{
			var consoleText:String = console_input.text;
			var splittedText:Array = consoleText.split(" ");
			var commandName:String = splittedText[0]; //Guardo el nombre del comando que SIEMPRE va a ser el índice 0.
			
			//Elimino el nombre del comando...
			splittedText.shift(); //Elimina el primer elemento de un array.
			
			var cData:CommandData = allCommands[commandName];
			
			if(cData != null)
			{
				try
				{
					cData.command();
				}
				catch(e1:ArgumentError)
				{
					if(splittedText.length > 0)
					{
						try
						{
							cData.command.apply(this, splittedText);
						}
						catch (e3:ArgumentError)
						{
							write("La cantidad de argumentos es inválida.");
						}
						catch (e4:Error)
						{
							trace("Error raro: " + "\n" + e4.name + "\n" + e4.getStackTrace());
						}
					}
					else
					{
						write("El comando esperaba al menos un parámetro.");
					}
				}
				catch(e2:Error)
				{
					trace("Error raro: " + "\n" + e2.name + "\n" + e2.getStackTrace());
				}
			}
			else
			{
				write("Bad command.");
			}
			
			console_input.text = "";
		}
		
		public function write(text:String):void
		{
			console_log.appendText(text + "\n");
		}
		
		public function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.F8)
			{
				isOpen ? close() : open();
				isOpen = !isOpen;
				
				//Locator.mainStage.currentState
			}
			else if (isOpen && e.keyCode == Keyboard.ENTER)
			{
				execCommand();
			}
		}
		
		public function open():void
		{
			Locator.mainStage.addChild(container);
			Locator.mainStage.focus = console_input;
		}
		
		public function close():void
		{
			Locator.mainStage.removeChild(container);
			Locator.mainStage.focus = Locator.mainStage;
		}
	}
}