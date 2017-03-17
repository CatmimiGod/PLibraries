package flash.window2
{
	import flash.external.ExternalInterface;

	public class FlashPlayerController
	{
		private var _x:int = 0;
		private var _y:int = 0;
		
		private var _width:uint = 100;
		private var _height:uint = 100;
		
		private var _visible:Boolean;
		private var _swfURL:String;
		
		private var _focused:Boolean;
		
		public function FlashPlayerController(pic:PrivateInternalClass)
		{
			//优先提供回调函数
			ExternalInterface.addCallback("callBackFlashPlayerInfo", callBackFlashPlayerInfo);
		}
		
		/**
		 *	@private 用于实时获取FlashPlayerControl位于C#窗体中的参数
		 * 	@param args
		 */
		private function callBackFlashPlayerInfo(...args):void
		{
			if(args.length != 7)
				return;
			
			this._x = int(args[0]);
			this._y = int(args[1]);
			this._width = uint(args[2]);
			this._height = uint(args[3]);
			
			this._visible = args[4].toLowerCase() == "true";
			this._swfURL = args[5];
			
			this._focused = args[6].toLowerCase() == "true";
		}
		
		public function setSize(x:int, y:int, width:uint, height:uint):void
		{
			ExternalInterface.call("swfSize", x, y, width, height);
		}
		
		public function get x():int{	return _x;	}
		public function set x(value:int):void
		{
			this._x = value;
			ExternalInterface.call("swfSize", _x, _y, _width, _height);
		}
		
		public function get y():int{	return _y;	}
		public function set y(value:int):void
		{
			this._y = value;
			ExternalInterface.call("swfSize", _x, _y, _width, _height);
		}
		
		public function get width():uint{	return _width;	}
		public function set width(value:uint):void
		{
			this._width = value;
			ExternalInterface.call("swfSize", _x, _y, _width, _height);
		}
		
		public function get height():uint{	return _height;	}
		public function set height(value:uint):void
		{
			this._height = value;
			ExternalInterface.call("swfSize", _x, _y, _width, _height);
		}
		
		public function get visible():Boolean{	return _visible;	}
		public function set visible(value:Boolean):void
		{
			this._visible = value;			
			ExternalInterface.call("swfVisible", this._visible);
		}
		
		public function get focused():Boolean{	return _focused;	}
		public function set focused(value:Boolean):void
		{
			_focused = value;
			ExternalInterface.call("swfFocus", _focused);
		}
		
		public function get swfURL():String{	return _swfURL;		}
	}
}