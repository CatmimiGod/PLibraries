package flash.template
{
	import flash.controller.KeyboardController;
	import flash.controller.NetworkController;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.ui.Mouse;
	import flash.utils.setTimeout;
	import flash.utils.getDefinitionByName;
	
	/**
	 *	Demo Application Template 	PC端通用模板
	 * 	@author Huangmin
	 */	
	[SWF(frameRate="25", backgroundColor="0x000000")]
	public class DemoApplicationTemplate extends Sprite
	{
		/**	可用语言列表	*/
		public static const LANGUAGES:Vector.<String> = new <String>["en", "cn"];
		
		/**	默认语言	*/
		private var _language:String = "cn";
		/**	是否使用多语言，默认为false	*/
		private var _multiLanuage:Boolean = false;
		
		/**	@private 配置文件路径 */		
		private var _configUrl:String;		
		/**	配置文件数据	*/
		protected var configData:XML;
		
		/**	网络控制器	*/
		protected var networkController:NetworkController;		
		/**	键盘控制器	*/
		protected var keyboardController:KeyboardController;
		
		/**
		 *	Demo Application Template. 
		 */		
		public function DemoApplicationTemplate()
		{
			XML.prettyIndent = 4;
			XML.ignoreComments = true;
		}
		
		/**	加载配置文件 */		
		protected function loaderConfiguration(url:String):void
		{
			_configUrl = url;
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			
			if(Capabilities.playerType == "Desktop")
			{
				var Application:Class = getDefinitionByName("flash.desktop.NativeApplication") as Class;
				Application.nativeApplication.addEventListener(Event.EXITING, onRemoveFromStage);
			}
			
			var loader:URLLoader = new URLLoader(new URLRequest(_configUrl));
			loader.addEventListener(Event.COMPLETE, onLoaderCompleteHandler, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoaderIOErrorHandler, false, 0, true);
		}
		
		/**	@private	配置加载完成	*/
		private function onLoaderCompleteHandler(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderIOErrorHandler);
			
			this.configData = XML(e.target.data);
			this.parseDefaultConfig();
			
			this._configUrl = null;
		}
		
		/**	@private	配置加载错误	*/
		private function onLoaderIOErrorHandler(e:IOErrorEvent):void
		{
			e.target.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderIOErrorHandler);
			
			throw new Error("配置文件加载错误，文件 " + this._configUrl + " 不存在。");
		}
		
		/**	解析默认的配置数据，在initialize()之前。*/		
		protected function parseDefaultConfig():void
		{
			//trace("parseXML");
			/** @internal 设置舞台属性	*/
			if(this.configData.hasOwnProperty("stage"))
			{
				/**  @internal 	是否是多语言Demo, 如果是则设置默认显示的语言	*/
				_multiLanuage = this.configData.stage.hasOwnProperty("@defaultLanguage");
				if(_multiLanuage)
					_language = this.configData.stage.@defaultLanguage.toLowerCase();
					//setLanguage(this.configData.stage.@defaultLanguage.toLowerCase());
				
				/** @internal	是否可用鼠标进行场景交互	*/
				if(this.configData.stage.hasOwnProperty("@mouseEnabled"))
					this.mouseEnabled = this.mouseChildren = this.configData.stage.@mouseEnabled == "true";
				
				/** @internal	是否隐藏鼠标光标	*/
				if(this.configData.stage.hasOwnProperty("@hideMouse") && this.configData.stage.@hideMouse == "true")
					Mouse.hide();
				
				/** @internal 是否全屏锁定	*/
				if(Capabilities.playerType != "ActiveX" && configData.stage.hasOwnProperty("displayState") && configData.stage.displayState.toString().indexOf("fullScreen") != -1)
				{
					if(configData.stage.displayState.hasOwnProperty("@lock") && configData.stage.displayState.@lock == "true")
					{
						this.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEventHandler);
					}
				}
				
				/**	 @internal 遍历属性	*/
				for each(var node:XML in configData.stage.children())
				{
					var prop:String = node.localName();
					if(prop != null)
					{
						if(prop == "displayState")
							stage[prop] = Capabilities.playerType != "ActiveX" ? configData.stage[prop] : StageDisplayState.NORMAL; 
						else
							stage[prop] = configData.stage[prop];
					}
				}
			}//End Stage Config Parse
			
			/**	 @internal 	网络控制器	*/
			if(this.configData.hasOwnProperty("network") && configData.network.@enabled == "true")
				networkController = new NetworkController(this, configData.network);
			
			/**	 @internal 	键盘控制器	*/
			if(this.configData.hasOwnProperty("keyboard") && configData.keyboard.@enabled == "true")
			{
				var keyUp:Boolean = !configData.keyboard.hasOwnProperty("@listenerKeyUp") ? true : configData.keyboard.hasOwnProperty("@listenerKeyUp") && configData.keyboard.@listenerKeyUp == "true" ? true : false;
				keyboardController = new KeyboardController(this, keyUp,
													configData.keyboard.hasOwnProperty("@listenerKeyDown") && configData.keyboard.@listenerKeyDown == "true");
				keyboardController.parseConfig(configData.keyboard);
			}
			
			initialize();
		}
		
		/**	初使化 程序*/		
		protected function initialize():void
		{
			deleteDefaultConfig();
		}
		
		/**
		 *	语言 <b>变更完成后</b> 调用；继承时调用，如果没有多语言选择，则不需要继承此方法<br />
		 * 	若想获取当前语言类型，请使用language属性获取
		 */		
		protected function languageChanged():void{}
		
		/**
		 *	设置语言.<b>此方法只用于外部调用或远程调用的语言切换接口，不可继承重写；如需继承重写请使用languageChanged方法</b><br />
		 * @param lang	语言字符简小写; 如果为空，则语言切换到上一种语言(中英文反转)
		 */		
		public final function setLanguage(lang:String = null):void
		{
			if(!_multiLanuage)
			{
				trace("setLanguage() 没有多语言可选择设置。");
				return;
			}
			
			if(lang == null)
			{
				_language = _language == "en" ? "cn" : "en";
				languageChanged();
			}
			else
			{
				lang = lang.toLowerCase();
				if(_language != lang && LANGUAGES.indexOf(lang) != -1)
				{
					_language = lang;
					languageChanged();
				}
			}
		}
		
		/**	退出演示程序，此方法只针对Window系统*/		
		public final function exit():void
		{
			onRemoveFromStage(null);
			DemoUtils.exit();
		}
		
		/**	重启演示程序，此方法只针对Window系统 */		
		public final function restart():void
		{
			DemoUtils.restart();
		}
		
		/** 当前对象从场景移除时需处理的对象*/
		protected function onRemoveFromStage(e:Event = null):void
		{
			trace("Remove");
			if(networkController)	networkController.dispose();			
			if(keyboardController)	keyboardController.dispose();
			if(configData)	System.disposeXML(configData);
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		/**	@private	删除默认的配置数据，网络配置节点，键盘配置节点，场景配置节点 		*/
		private function deleteDefaultConfig():void
		{
			if(this.configData == null)	return;
			
			if(this.configData.hasOwnProperty("stage"))
				delete configData.stage;
			
			if(this.configData.hasOwnProperty("network"))
				delete configData.network;
			
			if(this.configData.hasOwnProperty("keyboard"))
				delete configData.keyboard;
		}
		
		/**	 @private 	窗口尺寸调整事件*/		
		private function onFullScreenEventHandler(e:Event):void
		{
			setTimeout(fullScreenInteractive, 10);
		}
		private function fullScreenInteractive():void
		{
			if(stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE)
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}
		
		/**	获取当前显示的语言类型	*/
		public function get language():String{	return _language;	}
		
		/**	获取当前Demo是否是多语言类型	*/
		public function get multiLanguage():Boolean{		return _multiLanuage;	}
		
	}
}