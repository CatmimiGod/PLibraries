package flash.window2
{
	public class WindowsFormsApplication
	{
		public function WindowsFormsApplication()
		{
		}
		
		private static var _fpWindow:FlashPlayerController;
		public static function getFlashPlayerWindow():FlashPlayerController
		{
			if(_fpWindow == null)
				_fpWindow = new FlashPlayerController(new PrivateInternalClass());
			
			return _fpWindow;
		}
		
		private static var _vpWindow:VideoPlayerController;
		public static function getVideoPlayerWindow():VideoPlayerController
		{
			if(_vpWindow == null)
				_vpWindow = new VideoPlayerController(new PrivateInternalClass());
			
			return _vpWindow;
		}
		
		private static var _wbWindow:WebBrowserController;
		public static function getWebBrowserWindow():WebBrowserController
		{
			if(_wbWindow == null)
				_wbWindow = new WebBrowserController(new PrivateInternalClass());
			
			return _wbWindow;
		}
		
		private static var _wkbWindow:WebKitBrowserController;
		public static function getWebKitBrowserWindow():WebKitBrowserController
		{
			if(_wkbWindow == null)
				_wkbWindow = new WebKitBrowserController(new PrivateInternalClass());
			
			return _wkbWindow;
		}
		
	}
}