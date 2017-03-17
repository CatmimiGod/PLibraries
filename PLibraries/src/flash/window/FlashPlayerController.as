package flash.window
{
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.utils.Base64;

	/**
	 *	C#窗体中ShockwaveFlash容器对象，此对象不可实例化，需通过Application.getFlashPlayerInstance()获取实例；
	 * @author Administrator
	 */	
	public final class FlashPlayerController extends EventDispatcher
	{
		private var _childIndex:uint = 0;
		private var _visible:Boolean = false;
		private var _size:Rectangle = new Rectangle();
		
		private var _url:String = "";
		private var _focused:Boolean;
		
		/**
		 *	Constructor. 
		 */		
		public function FlashPlayerController(pic:PrivateInternalClass)
		{
			//优先提供回调函数
			ExternalInterface.addCallback("callBackFlashPlayerInfo", callBackFlashPlayerInfo);
			
			this._visible = true;			
			ExternalInterface.call("flashPlayerEnabled", true);
		}
		
		/**
		 *	@private 用于实时获取FlashPlayerControl位于C#窗体中的参数
		 * 	@param args
		 */
		private function callBackFlashPlayerInfo(...args):void
		{
			if(args.length != 8)
				return;
			
			_size.x = int(args[0]);
			_size.y = int(args[1]);
			_size.width = int(args[2]);
			_size.height = int(args[3]);
			
			_visible = args[4].toLowerCase() == "true";
			_childIndex = uint(args[5]);
			
			_url = args[6]
			_focused = args[7].toLowerCase() == "true";
		}
		
		/**
		 *	设置控件焦点，以接收键盘事件 
		 */		
		public function focus():void
		{
			ExternalInterface.call("swfFocus");	
		}
		/**	获取控件是否具有输入焦点	*/
		public function get focused():Boolean{	return _focused;	}
		
		/**
		 *	加载FlashPlayer内容文件，将由 url 指定的影片载入到由 layer 指定的层上
		 * @param url:String	文件路径
		 * @param layer:uint	文件显示层
		 */		
		public function loadMovie(url:String, layer:uint = 0):void
		{
			ExternalInterface.call("swfLoadMovie", Base64.encode(url), "base64", layer);
		}
		
		/**	获取或设置FlashPlayer窗口内容的URL地址*/	
		public function get url():String{		return this._url;	}
		public function set url(value:String):void
		{
			if(value == null)	return;
			
			this._url = value;
			ExternalInterface.call("swfURL", Base64.encode(value), "base64");
		}
		
		/**	获取或设置FlashPlayer窗口的可见性*/		
		public function get visible():Boolean{	return this._visible;	}
		public function set visible(value:Boolean):void
		{
			this._visible = value;
			ExternalInterface.call("swfVisible", value.toString());
		}
		
		/**	获取或设置FlashPlayer窗口的位置及大小*/	
		public function get size():Rectangle{		return this._size;	}
		public function set size(value:Rectangle):void
		{
			if(value == null)	return;
			
			this._size = value;
			var params:String = Math.round(value.x) + "," + Math.round(value.y) + "," + Math.round(value.width) + "," + Math.round(value.height);
			ExternalInterface.call("swfSize", params);
		}
		
		/**	获取或设置FlashPlayer窗口的层级顺序*/	
		public function get childIndex():uint{		return _childIndex;		}
		public function set childIndex(value:uint):void
		{
			_childIndex = value;
			ExternalInterface.call("swfChildIndex", value);
		}
		
	}
}

