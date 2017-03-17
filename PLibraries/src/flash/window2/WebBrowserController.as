package flash.window2
{
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	
	/**
	 *	C#窗体中IE浏览器容器对象，此对象不可实例化，需通过Application.getWebBrowseInstance()获取实例；
	 * @author Administrator
	 * 
	 */ 
	public final class WebBrowserController extends EventDispatcher
	{
		private var _size:Rectangle = new Rectangle();
		private var _visible:Boolean = false;
		private var _childIndex:uint = 0;
		
		private var _url:String = "http://www.spacecg.cn";
		private var _title:String = "";
		
		private var _focused:Boolean;
		private var _zoom:uint = 100;
		
		/**
		 *	Constructor. 
		 */		
		public function WebBrowserController(pic:PrivateInternalClass)
		{
			//优先提供回调函数
			ExternalInterface.addCallback("callBackWebBrowserInfo", callBackWebBrowserInfo);
			
			ExternalInterface.call("webBrowserEnabled", true);	
			this.url = _url;
			this._visible = true;
		}
		
		/**
		 *	@private 用于实时获取WebBrowserControl位于C#窗体中的参数
		 * 	@param args
		 */
		private function callBackWebBrowserInfo(...args):void
		{
			if(args.length != 8)
				return;
			
			_size.x = int(args[0]);
			_size.y = int(args[1]);
			_size.width = int(args[2]);
			_size.height = int(args[3]);			
			_visible = args[4].toLowerCase() == "true";
			
			_url = args[5];
			_title = args[6];
			
			_focused = args[7].toLowerCase() == "true";
			_zoom = uint(args[8]);
		}
		
		/**如果导航历史记录中的上一页可用，则将导航到该页*/
		public function goBack():void
		{
			ExternalInterface.call("webBrowserGoBack");
		}
		
		/**如果导航历史记录中的下一页可用，则将导航到该页*/
		public function goForward():void
		{
			ExternalInterface.call("webBrowserGoForward");
		}
		
		/**刷新页面内容*/
		public function refresh():void
		{
			ExternalInterface.call("webBrowserRefresh");
		}
		
		/**停止加载内容*/
		public function stop():void
		{
			ExternalInterface.call("webBrowserStop");
		}
		
		/**	获取控件是否具有输入焦点	*/
		public function get focused():Boolean{	return _focused;	}
		
		/**
		 *	设置控件焦点，以接收键盘输入事件 
		 */		
		public function focus():void
		{
			ExternalInterface.call("webBrowserFocus");	
		}
		
		/**	获取或设置WebBrowser窗口的位置及大小*/	
		public function get size():Rectangle{		return _size;	}
		public function set size(value:Rectangle):void
		{
			if(value == null)	return;
			
			this._size = value;
			var params:String = Math.round(value.x) + "," + Math.round(value.y) + "," + Math.round(value.width) + "," + Math.round(value.height);
			ExternalInterface.call("webBrowserSize", params);
		}
		
		/**	获取或设置WebBrowser窗口的可见性*/		
		public function get visible():Boolean{	return this._visible;	}
		public function set visible(value:Boolean):void
		{
			this._visible = value;
			ExternalInterface.call("webBrowserVisible", value.toString());
		}
		
		/**	获取或设置WebBrowser窗口当前的URL地址*/	
		public function get url():String{		return _url;	}
		public function set url(value:String):void
		{
			if(value == null)	return;
			
			this._url = value;
			ExternalInterface.call("webBrowserURL", value);
		}
		
		public function get zoom():uint{	return _zoom;	}
		public function set zoom(value:uint):void
		{
			_zoom = value;
			ExternalInterface.call("webBrowserZoom", _zoom);
		}
		
		/**文档标题*/
		public function get title():String{	return this._title;	}
		
	}
}
