package flash.mwc2016
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.template.DemoApplicationTemplate;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	
	/**
	 * 	加载列表模版
	 * @author Administrator
	 */	
	public class LoaderListTemplate extends DemoApplicationTemplate
	{
		private var _loader:Loader;
		
		protected var _background:DisplayObject;
		protected var _contentPage:DisplayObject;
		protected var _controlUI:MovieClip;
		
		private var _length:uint = 0;
		private var _selectedIndex:int = -1;
		
		/**
		 *	Constructor. 
		 */		
		public function LoaderListTemplate()
		{
			super.loaderConfiguration("assets/config.xml");
		}
		
		/**	initialize	*/
		override protected function initialize():void
		{
			if(configData.content[language].hasOwnProperty("@defaultID") && configData.content[language].@defaultID != "")
				_selectedIndex = int(configData.content[language].@defaultID);
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderContentComplete);
			
			//加载控制UI
			if(configData.content.hasOwnProperty("@controlUI") && configData.content.@controlUI != "")
			{
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderControlUIComplete, false, 0, true);
				loader.load(new URLRequest(configData.content.@controlUI));
			}
			
			languageChanged();
		}
		/**	语言切换处理	*/
		override protected function languageChanged():void
		{
			_length = configData.content[language].children().length();
			
			/**
			 * @internal	如果没有主页，就加载子级列表内容
			 */
			if(configData.content[language].hasOwnProperty("@background") && configData.content[language].@background != "")
			{
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderBackgroundComplete, false, 0, true);
				loader.load(new URLRequest(configData.content[language].@background));
			}
			else
			{
				loaderPage(_selectedIndex);
			}
			
			if(_controlUI != null && _controlUI.hasOwnProperty("setLanguage"))
				_controlUI.setLanguage(language);
		}
		
		/**
		 *	加载控制UI完成 
		 * @param e
		 */		
		protected function onLoaderControlUIComplete(e:Event):void
		{
			_controlUI = e.target.content;
			this.addChild(_controlUI);
			
			if(_controlUI.hasOwnProperty("target"))
				_controlUI.target = this;
			
			trace("加载控制UI完成 .... ");
			e.target.removeEventListener(Event.COMPLETE, onLoaderControlUIComplete);
		}
		
		/**
		 *	加载背景内容完成
		 * @param e
		 */		
		protected function onLoaderBackgroundComplete(e:Event):void
		{
			if(_background != null)
			{
				this.removeChild(_background);
				_background = null;
			}
			
			_background = e.target.content;
			this.addChildAt(_background, 0);
			if(_background is Bitmap)
				(_background as Bitmap).smoothing = true;
			
			trace("加载背景或主页完成 .... ");
			e.target.removeEventListener(Event.COMPLETE, onLoaderBackgroundComplete);
			
			loaderPage(_selectedIndex);
		}
		
		/**
		 *	加载子级页面内容完成
		 * @param e
		 */		
		protected function onLoaderContentComplete(e:Event):void
		{
			if(_contentPage != null)
			{
				this.removeChild(_contentPage);
				_contentPage = null;
			}
			
			_contentPage = e.target.content;
			this.addChild(_contentPage);
			if(_contentPage is Bitmap)
				(_contentPage as Bitmap).smoothing = true;
			
			trace("加载子页完成 ..... " + _selectedIndex + "/" + _length);
			if(_controlUI != null)
				this.setChildIndex(_controlUI, this.numChildren - 1);
		}
		
		/**
		 *	加载指定的页面 
		 * @param index
		 */	
		public function loaderPage(index:int):void
		{
			if(index < -1 && index > _length)
				throw new ArgumentError("加载内容索引超出范围...." + index);
			
			if(_selectedIndex != index)
				_selectedIndex = index;
			
			//_loader.unload();
			_loader.unloadAndStop();
			this.dispatchEvent(new Event(Event.CHANGE));
			
			/**
			 * @internal	-1表示回到主界面，清除当前内容页面
			 */
			if(index == -1)
			{
				if(_contentPage != null)
					this.removeChild(_contentPage);
				
				_contentPage = null;				
				return;
			}
			
			var url:String = configData.content[language].children().(@id == index).@url;
			if(url == null || url == "")
				throw new ArgumentError("配置错误，指定的路径错误！ language:" + language + "  id:" + index + "  url:" + url);
			
			trace("加载内容：language:" + language + "  id:" + index + "  url:" + url);
			_loader.load(new URLRequest(url));
		}
		
		/**
		 *	下一页 
		 */		
		public function nextPage():void
		{
			var index:int = _selectedIndex + 1 > _length - 1 ? 0 : _selectedIndex + 1;
			
			loaderPage(index);
		}
		
		/**
		 *	上一页 
		 */		
		public function prevPage():void
		{
			var index:int = _selectedIndex - 1 < 0 ? _length - 1 : _selectedIndex - 1;
			
			loaderPage(index);
		}
		
		/**	返回背景或主页面内容	*/
		public function get background():Object{	return _background;		}
		
		/**	返回当前页面内容 	*/		
		public function get currentPage():Object{		return _contentPage;		}
		
		/**	返回控制UI对象		 */
		public function get controlUI():MovieClip{	return _controlUI;		}
		
		
		/**	返回子级内容列表长度	 */		
		public function get length():int{		return _length;		}
		
		/**	获取当前显示的页面索引	*/		
		public function get selectedIndex():int{		return _selectedIndex;		}
		
	}
}