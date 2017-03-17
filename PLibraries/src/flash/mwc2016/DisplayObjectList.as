package flash.mwc2016
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	[Event(name="complete", type="flash.events.Event")]
	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 *	2016巴展项目，独立对象，上下切换页面内容
	 * 	@author Administrator
	 */	
	public final class DisplayObjectList extends Sprite
	{
		private var _loader:Loader;
		private var _preload:Boolean = false;
		
		private var _background:DisplayObject
		private var _contentPage:DisplayObject;
		private var _contentList:Vector.<DisplayObject>;
		
		private var _config:XML;
		private var _length:uint = 0;
		private var _selectedIndex:int = -1;
		
		/**	鼠标交互事件处理函数, onMouseInteractionHandler(e:MouseEvent)	 */		
		public var onMouseInteractionHandler:Function;
		
		/**
		 * Constructor.
		 * @param list
		 */		
		public function DisplayObjectList(list:XML = null, preload:Boolean = false)
		{
			_preload = preload;
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			
			loaderList(list);
		}
		
		/**
		 *	加载列表配置 
		 * 	@param list
		 */		
		public function loaderList(list:XML):void
		{
			if(list == null)	return;
			if(list.children().length() <= 0)	return;
			
			_config = list;
			_length = _config.children().length();
			_selectedIndex = _config.hasOwnProperty("@defaultID") && _config.@defaultID != "" ? int(_config.@defaultID) : _selectedIndex;
			
			/**
			 * @internal	加载背景内容
			 */
			if(_config.hasOwnProperty("@background") && _config.@background != "")
			{
				_loader.name = "background";
				_loader.load(new URLRequest(_config.@background));
			}
			else
			{
				firstLoader();
			}
		}
		private function firstLoader():void
		{
			var url:String = "";
			
			if(_preload)
			{
				_contentList = new Vector.<DisplayObject>(_length, true);
				url = _config.children().(@id == "0")[0].@url
				
				_loader.name = "preload_0";
				_loader.load(new URLRequest(url));
			}
			else
			{
				if(_selectedIndex == -1)	return;				
				url = _config.children().(@id == _selectedIndex)[0].@url;
				
				_loader.name = "contentPage";				
				_loader.load(new URLRequest(url));
			}
		}
		
		//Loader Complete Event Handler
		private function onLoaderCompleteHandler(e:Event):void
		{
			var cfg:XML;
			var contentType:String = e.target.loader.name;
			trace(_selectedIndex, contentType);
			
			switch(contentType)
			{
				case "background":
					if(_background != null)
					{
						this.removeChild(_background);
						_background = null;
					}
					
					_background = e.target.content;
					if(_background is Bitmap)
						(_background as Bitmap).smoothing = true;
					this.addChildAt(_background, 0);
					trace("Loader Background Complete ... ");
					
					firstLoader();
					break;
				
				case "contentPage":
					if(_contentPage != null)
					{
						this.removeChild(_contentPage);
						_contentPage = null;
					}
					
					_contentPage = e.target.content;
					if(_contentPage is Bitmap)	
						(_contentPage as Bitmap).smoothing = true;
					this.addChild(_contentPage);
					
					//添加鼠标交互事件
					cfg = _config.children().(@id == _selectedIndex)[0];
					if(cfg != null && onMouseInteractionHandler != null && cfg.hasOwnProperty("@listenerClick") && cfg.@listenerClick == "true")
						_contentPage.addEventListener(MouseEvent.CLICK, onMouseInteractionHandler, false, 0, true);
					
					this.dispatchEvent(new Event(Event.COMPLETE));
					trace("Loader Contnent Complete ... ", _selectedIndex + "/" + _length);
					break;
				
				default:
					if(contentType.indexOf("preload_") == -1)	return;					
					var id:int = int(e.target.loader.name.replace("preload_", ""));
					
					_contentList[id] = e.target.content;						trace(id + "/" + _length, _contentList[id]);
					_contentList[id].visible = id == _selectedIndex;
					this.addChild(_contentList[id]);
					//平滑图片
					if(_contentList[id] is Bitmap) (_contentList[id] as Bitmap).smoothing = true;
					
					//添加鼠标交互事件
					cfg = _config.children().(@id == id)[0];
					if(cfg != null && onMouseInteractionHandler != null && cfg.hasOwnProperty("@listenerClick") && cfg.@listenerClick == "true")
						_contentList[id].addEventListener(MouseEvent.CLICK, onMouseInteractionHandler, false, 0, true);
					
					if(id < _length -1)
					{
						_loader.name = "preload_" + (++ id);
						_loader.load(new URLRequest(_config.children().(@id == id)[0].@url));
					}
					else
					{
						//_config = null;
						//_loader.unloadAndStop();
						
						trace("Loader complete ... ");
						//默认显示第一页
						setInteractionPage(_selectedIndex);
						this.dispatchEvent(new Event(Event.COMPLETE));
					}
			}
		}
		
		/**
		 *	设置交互显示页面 
		 * @param index:int
		 */		
		protected function setInteractionPage(index:int):void
		{
			for(var i:int = 0; i < _length; i ++)
			{
				_contentList[i].visible = i == index;
				
				if(_contentList[i] is DisplayObjectContainer)
					(_contentList[i] as DisplayObjectContainer).mouseEnabled = (_contentList[i] as DisplayObjectContainer).mouseChildren = i == index;
			}
			
			if(_selectedIndex == index)	return;			
			_selectedIndex = index;
			
			var event:Event = new Event(Event.CHANGE, false, true);
			this.dispatchEvent(event);
			
			/**
			 * @internal	事件的默认行为
			 */
			if(!event.isDefaultPrevented())
			{
				if(currentPage && currentPage is MovieClip)
					(currentPage as MovieClip).gotoAndPlay(1);
			}
		}
		
		/**
		 *	加载指定的页面 
		 * @param index
		 */	
		public function loaderPage(index:int):void
		{
			if(_preload)	
			{
				gotoPage(index);
				return;
			}
			
			if(index < -1 && index > _length)
				throw new ArgumentError("加载内容索引超出范围...." + index);
			
			if(_selectedIndex != index)
				_selectedIndex = index;
			
			_loader.unloadAndStop();
			
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
			
			var url:String = _config.children().(@id == index).@url;
			if(url == null || url == "")
				throw new ArgumentError("配置错误，指定的路径错误！  id:" + index + "  url:" + url);
			
			_loader.name = "contentPage";
			_loader.load(new URLRequest(url));
		}
		
		/**
		 *	跳到指定的页面 
		 * @param index
		 */		
		public function gotoPage(index:int):void
		{
			if(!_preload)	
			{
				loaderPage(index);
				return;
			}
			
			if(index < -1 && index >= _length)	return;
			
			setInteractionPage(index);
		}
		
		/**
		 *	下一页 
		 */		
		public function nextPage():void
		{
			var index:int = _selectedIndex + 1 > _length - 1 ? 0 : _selectedIndex + 1;
			
			_preload ? gotoPage(index) : loaderPage(index);
		}
		
		/**
		 *	上一页 
		 */		
		public function prevPage():void
		{
			var index:int = _selectedIndex - 1 < 0 ? _length - 1 : _selectedIndex - 1;
			
			_preload ? gotoPage(index) : loaderPage(index);
		}
		
		/**	返回当前页面内容 	*/		
		public function get currentPage():Object
		{		
			if(_preload)
			{
				if(_selectedIndex == -1 || _contentList == null)
					return null;
				
				return _contentList[_selectedIndex];
			}
			
			return _contentPage;		
		}
		
		/**	返回背景或主页面内容	*/
		public function get background():Object{	return _background;		}
		
		/**	返回子级内容列表长度	 */		
		public function get length():int{		return _length;		}
		
		/**	获取当前显示的页面索引	*/		
		public function get selectedIndex():int{		return _selectedIndex;		}
		
		
		
	}
}