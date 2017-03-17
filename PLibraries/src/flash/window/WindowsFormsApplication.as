package flash.window
{
	//import flash.errors.IllegalOperationError;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;

	/**
	 * 用于控制C#窗体容器的类
	 * @author Administrator
	 * @playerversion Flash Player 11.5
	 * @date 2000.12.12
	 * @update 2010
	 */	
	public final class WindowsFormsApplication
	{
		/**	C#窗体中ShockwaveFlash容器名称 */		
		public static const SHOCKWAVE_FLASH:String = "ShockwaveFlash";
		
		/**	C#窗体中WindowsMediaPlayer容器名称 */
		public static const WINDOW_MEDIA_PLAYER:String = "WindowsMediaPlayer";
		
		/**	C#窗体中WebBrowse容器名称 */
		public static const WEB_BROWSE:String = "WebBrowse";
		
		/**	C#窗体中WebKitBrowse容器名称 */
		public static const WEBKIT_BROWSE:String = "WebKitBrowse";
		
		/**	C#窗体中用于调试的容器名称 */
		public static const DEBUG_CONTROL:String = "DebugControl";
		
		private var _alwaysInFront:Boolean = true;
		private var _visible:Boolean = false;
		private var _size:Rectangle = new Rectangle();
		
		private var _state:String = "";
		private var _startupPath:String = "";
		
		public function WindowsFormsApplication(pic:PrivateInternalClass)
		{
			ExternalInterface.addCallback("callBackApplicationInfo", callBackApplicationInfo);
			
			this._visible = true;			
			ExternalInterface.call("windowEnabled", true);
		}
		
		/**
		 *	@private 用于实时获取应用程序窗体的参数
		 * 	@param args
		 */
		private function callBackApplicationInfo(...args):void
		{
			if(args.length != 8)
				return;
			
			_size.x = int(args[0]);
			_size.y = int(args[1]);
			_size.width = int(args[2]);
			_size.height = int(args[3]);
			
			_visible = args[4].toLowerCase() == "true";
			_alwaysInFront = args[5].toLowerCase() == "true";
			
			_state = args[6];
			_startupPath = args[7];
			//WindowsFormsApplication.getDebugInstance().consoleTrace(args.toString());
		}
		
		//VideoPlayerController
		private static var _vpInstance:VideoPlayerController;		
		/**	获取VideoPlayerController唯一实例 */		
		public static function getVideoPlayerInstance():VideoPlayerController
		{
			if(_vpInstance == null)
				_vpInstance = new VideoPlayerController(new PrivateInternalClass());
			
			return _vpInstance;
		}
		
		//FlashPlayerController
		private static var _fpInstance:FlashPlayerController;
		/**	获取FlashPlayerController唯一实例	*/
		public static function getFlashPlayerInstance():FlashPlayerController
		{
			if(_fpInstance == null)
				_fpInstance = new FlashPlayerController(new PrivateInternalClass());
			
			return _fpInstance;
		}
		
		private static var _wbInstance:WebBrowserController;
		/**获取WebBrowserController唯一实例*/
		public static function getWebBrowserInstance():WebBrowserController
		{
			if(_wbInstance == null)
				_wbInstance = new WebBrowserController(new PrivateInternalClass());
			
			return _wbInstance;
		}
		
		private static var _wkbInstance:WebKitBrowserController;
		/**获取WebKitBrowserController唯一实例*/
		public static function getWebKitBrowserInstance():WebKitBrowserController
		{
			if(_wkbInstance == null)
				_wkbInstance = new WebKitBrowserController(new PrivateInternalClass());
			
			return _wkbInstance;
		}
		
		private static var _debugInstance:DebugController;
		/**获取DebugController唯一实例*/
		public static function getDebugInstance():DebugController
		{
			if(_debugInstance == null)
				_debugInstance = new DebugController(new PrivateInternalClass());
			
			return _debugInstance;
		}
		
		private static var _application:WindowsFormsApplication;
		/**获取WindowsFormsApplication唯一实例*/
		public static function getApplicationInstance():WindowsFormsApplication
		{
			if(_application == null)
				_application = new WindowsFormsApplication(new PrivateInternalClass());
			
			return _application;
		}
		
		/**使此窗口最小化*/
		public function minimize():void
		{
			ExternalInterface.call("windowMinimize");
		}
		
		/**使此窗口最大化*/
		public function maximize():void
		{
			ExternalInterface.call("windowMaximize");
		}
		
		/** 关闭窗口及退出应用程序*/		
		public function exit():void
		{
			ExternalInterface.call("exit");
		}
		
		/**	获取或设置主窗体的可见性*/		
		public function get visible():Boolean{	return this._visible;	}
		public function set visible(value:Boolean):void
		{
			this._visible = value;
			ExternalInterface.call("windowVisible", value.toString());
		}
		
		/**	获取或设置主窗体的位置及大小*/	
		public function get size():Rectangle{		return this._size;	}
		public function set size(value:Rectangle):void
		{
			if(value == null)	return;
			
			this._size = value;
			var params:String = Math.round(value.x) + "," + Math.round(value.y) + "," + Math.round(value.width) + "," + Math.round(value.height);
			ExternalInterface.call("windowSize", params);
		}
		
		/**指定主窗体是否始终显示在其他窗口前面（包括其他应用程序的窗口）*/
		public function get alwaysInFront():Boolean{		return _alwaysInFront;	}
		public function set alwaysInFront(value:Boolean):void
		{
			this._alwaysInFront = value;
			ExternalInterface.call("windowAlwaysInFornt", this._alwaysInFront);
		}
		
		/**获取窗体状态*/
		public function get state():String{	return _state;	}
		/**应用程序的启动路径*/
		public function get startupPath():String{	return _startupPath;	}
		
		/**
		 *	日志记录 
		 * @param args
		 */		
		public static function logger(...args):void
		{
			if(args.length < 0)
				throw new ArgumentError("参数不能为空");
			
			var str:String = args.toString();
			ExternalInterface.call("logger", str);
		}
		
		
	}
}