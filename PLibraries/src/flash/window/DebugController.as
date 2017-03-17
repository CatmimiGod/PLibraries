package flash.window
{
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	
	/**
	 *	C#窗体中WDebugControl容器对象；此对象不可实例化，需通过Application.getDebugInstance()获取实例； 
	 * @author Administrator
	 * @example 应用示例
	 * <listing version="3.0">
	 * var debug:DebugControl = WindowsFormsApplication.getDebugInstance();
	 * debug.flashTrace("hello");
	 * //或
	 * WindowsFormsApplication.getDebugInstance().flashTrace("hello");
	 * </listing>
	 */	
	public class DebugController extends EventDispatcher
	{
		private var _childIndex:uint = 0;
		private var _visible:Boolean = false;
		private var _size:Rectangle = new Rectangle();
		
		/**
		 *	Constructor. 
		 * @param pic:PrivateInternalClass 内部私用类
		 */		
		public function DebugController(pic:PrivateInternalClass)
		{
			ExternalInterface.addCallback("callBackDebugInfo", callBackDebugInfo);
			
			this._visible = true;			
			ExternalInterface.call("debugEnabled", true);
		}
		
		/**
		 *	@private 用于实时获取DebugControl位于C#窗体中的参数
		 * 	@param args
		 */		
		private function callBackDebugInfo(...args):void
		{
			if(args.length != 6)
				return;
			
			_size.x = int(args[0]);
			_size.y = int(args[1]);
			_size.width = int(args[2]);
			_size.height = int(args[3]);
			
			_visible = args[4].toLowerCase() == "true";
			_childIndex = uint(args[5]);
			//this.consoleTrace("Flash INFO:" + args.toString());
		}
		
		/**
		 *	调试输出信息，用于Flash调试信息输出 
		 * @param args
		 */		
		public function flashTrace(...args):void
		{
			if(args.length < 0)
				throw new ArgumentError("参数不能为空");
			
			var str:String = args.toString();
			ExternalInterface.call("debugFlashTrace", str);
		}
		
		/**
		 * 控制台输出，用于C#调试。
		 * @param args
		 */		
		public function consoleTrace(...args):void
		{
			if(args.length < 0)
				throw new ArgumentError("参数不能为空");
			
			var str:String = args.toString();
			ExternalInterface.call("debugConsoleTrace", str);
		}
		
		/**
		 * Alert窗口
		 * @param message:String	提示信息
		 */		
		public function messageBox(message:String):void
		{
			if(message == null)
				throw new ArgumentError("参数不能为空");
			
			ExternalInterface.call("debugMessageBox", message);
		}
		
		/**	获取或设置调试窗口的可见性*/		
		public function get visible():Boolean{	return this._visible;	}
		public function set visible(value:Boolean):void
		{
			this._visible = value;
			ExternalInterface.call("debugVisible", value.toString());
		}
		
		/**	获取或设置调试窗口的位置及大小*/	
		public function get size():Rectangle{		return this._size;	}
		public function set size(value:Rectangle):void
		{
			if(value == null)	return;
			
			this._size = value;
			var params:String = Math.round(value.x) + "," + Math.round(value.y) + "," + Math.round(value.width) + "," + Math.round(value.height);
			ExternalInterface.call("debugSize", params);
		}
		
		/**	获取或设置调试窗口的层级顺序*/	
		public function get childIndex():uint{		return _childIndex;		}
		public function set childIndex(value:uint):void
		{
			_childIndex = value;
			ExternalInterface.call("debugChildIndex", value);
		}
		
	}
}