package flash.window
{
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.utils.Base64;
	
	/**
	 *	C#窗体中WebKit内核浏览器容器对象，此对象不可实例化，需通过Application.getWebBrowseInstance()获取实例；
	 * @author Administrator
	 * 
	 */ 
	public final class WebKitBrowserController extends EventDispatcher
	{
		private var _size:Rectangle = new Rectangle();
		private var _visible:Boolean = false;
		private var _childIndex:uint = 0;
		
		private var _url:String = "http://www.spacecg.cn";
		private var _title:String = "";
		
		private var _focused:Boolean;
		
		/**
		 *	Constructor. 
		 */		
		public function WebKitBrowserController(pic:PrivateInternalClass)
		{
			//优先提供回调函数
			ExternalInterface.addCallback("callBackWebKitBrowserInfo", callBackwebKitBrowserInfo);
			
			ExternalInterface.call("webKitBrowserEnabled", true);	
			this.url = _url;
			this._visible = true;
		}
		
		/**
		 *	@private 用于实时获取webKitBrowserControl位于C#窗体中的参数
		 * 	@param args
		 */
		private function callBackwebKitBrowserInfo(...args):void
		{
			if(args.length != 9)
				return;
			
			_size.x = int(args[0]);
			_size.y = int(args[1]);
			_size.width = int(args[2]);
			_size.height = int(args[3]);			
			_visible = args[4].toLowerCase() == "true";
			
			_childIndex = uint(args[5]);
			_url = args[6];
			_title = args[7];
			
			_focused = args[4].toLowerCase() == "true";
			//WindowsFormsApplication.getDebugInstance().consoleTrace(args.toString());
		}
		
		/**如果导航历史记录中的上一页可用，则将导航到该页*/
		public function goBack():void
		{
			ExternalInterface.call("webKitBrowserGoBack");
		}
		
		/**如果导航历史记录中的下一页可用，则将导航到该页*/
		public function goForward():void
		{
			ExternalInterface.call("webKitBrowserGoForward");
		}
		
		/**刷新页面内容*/
		public function refresh():void
		{
			ExternalInterface.call("webKitBrowserRefresh");
		}
		
		/**停止加载内容*/
		public function stop():void
		{
			ExternalInterface.call("webKitBrowserStop");
		}
		
		/**	获取控件是否具有输入焦点	*/
		public function get focused():Boolean{	return _focused;	}
		
		/**
		 *	设置控件焦点，以接收键盘输入事件 
		 */		
		public function focus():void
		{
			ExternalInterface.call("webKitBrowserFocus");	
		}
		
		/**	获取或设置webKitBrowser窗口的位置及大小*/	
		public function get size():Rectangle{		return _size;	}
		public function set size(value:Rectangle):void
		{
			if(value == null)	return;
			
			this._size = value;
			var params:String = Math.round(value.x) + "," + Math.round(value.y) + "," + Math.round(value.width) + "," + Math.round(value.height);
			ExternalInterface.call("webKitBrowserSize", params);
		}
		
		/**	获取或设置webKitBrowser窗口的可见性*/		
		public function get visible():Boolean{	return this._visible;	}
		public function set visible(value:Boolean):void
		{
			this._visible = value;
			ExternalInterface.call("webKitBrowserVisible", value.toString());
		}
		
		/**	获取或设置webKitBrowser窗口当前的URL地址*/	
		public function get url():String{		return _url;	}
		public function set url(value:String):void
		{
			if(value == null)	return;
			
			this._url = value;
			ExternalInterface.call("webKitBrowserURL", Base64.encode(value), "base64");
		}
		
		/**	获取或设置webKitBrowser窗口的层级顺序*/	
		public function get childIndex():uint{		return _childIndex;		}
		public function set childIndex(value:uint):void
		{
			_childIndex = value;
			ExternalInterface.call("webKitBrowserChildIndex", value);
		}
		
		/**文档标题*/
		public function get title():String{	return this._title;	}
		
	}
}


