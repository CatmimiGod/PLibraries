package flash.utils
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/**
	 *	读到ID卡读取完成时发生 
	 * @author Administrator
	 */	
	[Event(name="Event.COMPLETE", type="flash.events.Event")]
	
	/**
	 *	USB或PS2的ID读卡器输入 
	 * @author Administrator
	 */	
	public class IDReader extends EventDispatcher
	{
		//ID
		private var _id:String = "";
		
		/**
		 *	Constructor. 
		 * @param dis:DisplayObject
		 */		
		public function IDReader(view:DisplayObject)
		{
			if(view)
			{
				view.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyboardEventHandler);
				//view.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEventHandler);
			}
			else
			{
				throw new ArgumentError("IDReader()构造函数参数不能为空");
			}
		}
		
		/**
		 *	@private 
		 * 	键盘事件处理
		 */		
		private function onKeyboardEventHandler(e:KeyboardEvent):void
		{
			if(e.keyCode >= Keyboard.NUMBER_0 && e.keyCode <= Keyboard.NUMBER_9 || e.keyCode >= Keyboard.NUMPAD_0 && e.keyCode <= Keyboard.NUMPAD_9)
			{
				_id += String.fromCharCode(e.keyCode);
			}
			else if(e.keyCode == Keyboard.ENTER)
			{
				this.dispatchEvent(new Event(Event.COMPLETE));
				_id = "";
			}
			else
			{
				//sleep...
			}
		}
		
		/**
		 *	ID卡号 
		 */		
		public function get id():String{	return _id;		}
		
	}
}