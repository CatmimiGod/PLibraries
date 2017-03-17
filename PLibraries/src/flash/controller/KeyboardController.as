package flash.controller
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.utils.getDefinitionByName;
	

	/**
	 *  键盘控制器
	 * 	@author Huangm
	 */
	public final class KeyboardController
	{
		
		//View
		protected var _view:DisplayObjectContainer;
		
		/**  绑定的键盘与函数*/
		protected var _keyCodeFuncs:Vector.<KeyboardFunction>;
		
		/**
		 *	Contructor. 
		 * 	@param view:DisplayObject	视图对象
		 * 
		 * <listing version="3.0">
		 *  //键盘控制
		 *	var keyboardController:KeyboardController = new KeyboardController(this);
		 *	keyboardController.addKeyUpFunc(Keyboard.ENTER, mc.play);
		 *	keyboardController.addKeyDownFunc(Keyboard.A, mc.gotoAndPlay, 2);
		 *	keyboardController.addKeyDownFunc(Keyboard.B, testArgs, "hello", 250);
		 * 	//访问public变量
		 *	keyboardController.addKeyDownFunc(Keyboard.C, "testArgs", "hello", "%index%");
		 *	
		 *	keyboardController.removeKeyDownFunc(Keyboard.B);
		 * </listing>
		 */		
		public function KeyboardController(view:DisplayObjectContainer, listenerKeyUp:Boolean = true, listenerKeyDown:Boolean = false)
		{
			if(view == null)
				throw new ArgumentError("KeyboardController 参数不能为空。");
			
			_view = view;
			_keyCodeFuncs = new Vector.<KeyboardFunction>();
			
			var Application:Class;
			if(Capabilities.playerType == "Desktop")
				Application = getDefinitionByName("flash.desktop.NativeApplication") as Class;
			
			if(listenerKeyUp)
			{
				if(Capabilities.playerType == "Desktop")
					Application.nativeApplication.addEventListener(KeyboardEvent.KEY_UP, onKeyboardEventHandler, false, 0, true);
				else
					_view.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyboardEventHandler, false, 0, true);
			}
			
			if(listenerKeyDown)
			{
				if(Capabilities.playerType == "Desktop")
					Application.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEventHandler, false, 0, true);
				else
					_view.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEventHandler, false, 0, true);
			}
				
		}
		
		/**
		 *	 解析外部配置
		 * @param config:XML
		 */		
		public function parseConfig(config:Object):void
		{
			if(config.@enabled.toString().toLowerCase() == "true" && config.hasOwnProperty("key"))
			{
				var len:int = config.key.length();
				for(var i:int = 0; i < len; i ++)
				{
					var key:XML = config.key[i];
					if(key.hasOwnProperty("@code") && key.hasOwnProperty("@funcName"))
					{
						var obj:KeyboardFunction = new KeyboardFunction(uint(key.@code), key.@funcName.toString(), 
													key.hasOwnProperty("@args") && key.@args != "" ? key.@args.toString().split(",") : null,
													key.hasOwnProperty("@type") ? key.@type : KeyboardEvent.KEY_UP);
						
						if(getKeyCodeFuncIndex(obj.eventType, obj.keyCode) == -1)
							_keyCodeFuncs.push(obj);
						else
							throw new ArgumentError("KeyboardController:: 键值 keyCode: " + obj.keyCode + " 已与函数绑定。");
					}
				}//End for
			}
		}
		
		
		/**		清理。清理后请将此对象设为null	*/
		public function dispose():void
		{
			_view.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyboardEventHandler);
			_view.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEventHandler);

			_view = null;
			_keyCodeFuncs = null;
		}
		
		/**
		 *  @private
		 * 	键盘事件处理
		 */
		private function onKeyboardEventHandler(e:KeyboardEvent):void
		{
			trace("[KeyboardController::  KeyCode:" + e.keyCode + "  Event Type:" + e.type + "]");
			executingKeyboardFunc(e.type, e.keyCode);
		}
		
		
		/**
		 * 执行Keyboard事件函数
		 * @param type:String	事件类型
		 * @param keyCode:uint	键盘键值
		 */
		protected function executingKeyboardFunc(type:String, keyCode:uint):void
		{
			var index:int = getKeyCodeFuncIndex(type, keyCode);
			if(index != -1)
			{
				var obj:KeyboardFunction = _keyCodeFuncs[index];	
				obj.execute(_view);
			}
		}
		
		
		/**
		 *	获取键盘事件类型与 键值的索引值 
		 * @param type:String	键盘事件类型
		 * @param keyCode:uint	键盘键值
		 * @return 
		 */		
		protected function getKeyCodeFuncIndex(eventType:String, keyCode:uint):int
		{
			if(_keyCodeFuncs == null)
				return -1;
			
			var index:int = -1;
			var len:int = _keyCodeFuncs.length;
			
			for(var i:int = 0; i < len; i ++)
			{
				var obj:Object = _keyCodeFuncs[i];
				if(obj.eventType == eventType && obj.keyCode == keyCode)
				{
					index = i;
					break;
				}
			}
			
			return index;
		}
		
		/**
		 *	添加键盘键值与函数绑定，事件为KeyboardEvent.KEY_UP。 
		 * @param keyCode:uint		键盘键值
		 * @param funcOrName:Object	函数或函数名；<b>如果是函数名，则该函数必须声明为public类型</b>；如果是函数类型，则可为private或public、protected类型；
		 * @param ...args			函数参数，参数类型应为简单的字符或数字类型，如果要访问变量，必须以"%"开始和结尾且变量为public类型，例："%selectedindex%";
		 * 
		 * @throws ArgumentError 函数名不能为空
		 * @throws ArgumentError 键值已与函数绑定过
		 */		
		public function addKeyUpFunc(keyCode:uint, funcOrName:Object, ...args):void
		{
			if(_keyCodeFuncs == null)
				return;
			
			if(funcOrName == null)
				throw new ArgumentError("KeyboardController::addKeyUpFunc() 函数或函数名不能为空。");
			
			//var obj:Object = {keyCode:keyCode, funcName:funcOrName, args:length > 0 ? args : null, keyEventType:KeyboardEvent.KEY_UP};
			var obj:KeyboardFunction = new KeyboardFunction(keyCode, funcOrName, args, KeyboardEvent.KEY_UP);
			
			if(getKeyCodeFuncIndex(obj.eventType, obj.keyCode) == -1)
			{
				_keyCodeFuncs.push(obj);
			}
			else
			{
				throw new ArgumentError("KeyboardController::addKeyUpFunc() 键值keyCode:" + keyCode + " 已与函数绑定。");
			}
		}
		
		/**
		 * 移除键值与函数绑定，事件为KeyboardEvent.KEY_UP。
		 * 
		 * @param keyCode:uint	键盘键值
		 */
		public function removeKeyUpFunc(keyCode:uint):void
		{
			var index:int = getKeyCodeFuncIndex(KeyboardEvent.KEY_UP, keyCode);
			
			if(index != -1)
			{
				_keyCodeFuncs.splice(index, 1);
			}
		}
		
		
		/**
		 *	添加键盘键值与函数绑定，事件为KeyboardEvent.KEY_DOWN。 
		 * @param keyCode:uint		键盘键值
		 * @param funcOrName:Object	函数或函数名；<b>如果是函数名，则该函数必须声明为public类型</b>；如果是函数类型，则可为private或public、protected类型；
		 * @param ...args			函数参数，参数类型应为简单的字符或数字类型，如果要访问变量，必须以"%"开始和结尾且变量为public类型，例："%selectedindex%";
		 * 
		 * @throws ArgumentError 函数名不能为空
		 * @throws ArgumentError 键值已与函数绑定过
		 */	
		public function addKeyDownFunc(keyCode:uint, funcOrName:Object, ...args):void
		{
			if(_keyCodeFuncs == null)
				return;
			
			if(funcOrName == null)
				throw new ArgumentError("KeyboardController::addKeyDownFunc() 函数或函数名不能为空。");
			
			var obj:KeyboardFunction = new KeyboardFunction(keyCode, funcOrName, args, KeyboardEvent.KEY_DOWN)
			//var obj:Object = {keyCode:keyCode, funcName:funcOrName, args:args.length > 0 ? args : null, keyEventType:KeyboardEvent.KEY_DOWN};
			
			if(getKeyCodeFuncIndex(obj.eventType, obj.keyCode) == -1)
			{
				_keyCodeFuncs.push(obj);
			}
			else
			{
				throw new ArgumentError("KeyboardController::addKeyDownFunc() 键值 keyCode: " + keyCode + " 已与函数绑定。");
			}
		}
		
		/**
		 * 移除键值与函数绑定，事件为KeyboardEvent.KEY_DOWN。
		 * 
		 * @param keyCode:uint	键盘键值
		 */
		public function removeKeyDownFunc(keyCode:uint):void
		{
			var index:int = getKeyCodeFuncIndex(KeyboardEvent.KEY_DOWN, keyCode);
			
			if(index != -1)
			{
				_keyCodeFuncs.splice(index, 1);
			}
		}
		
		
	}
}


import flash.display.DisplayObject;
import flash.events.KeyboardEvent;

class KeyboardFunction
{
	public var keyCode:uint;
	public var eventType:String;
	
	public var funcOrName:Object;
	public var funcArgs:Array;
	
	/**
	 *	键盘与方法绑定对象 
	 * @param code
	 * @param funcOrName
	 * @param funcArgs
	 * @param eventType
	 */	
	public function KeyboardFunction(keyCode:uint, funcOrName:Object = null, funcArgs:Array = null, eventType:String = KeyboardEvent.KEY_UP):void
	{
		this.keyCode = keyCode;
		
		if(funcArgs != null)	this.funcArgs = funcArgs;
		if(eventType != null)	this.eventType = eventType;
		
		if(funcOrName != null)	this.funcOrName = funcOrName;
	}
	
	/**
	 *	执行方法 
	 * @param target:Object	 要应用该函数的对象
	 */	
	public function execute(target:Object):void
	{
		if(target == null)
			throw new Error("KeyboardFunction.execute::目标对象不能为空。 ");
		
		if(funcOrName == null)
			throw new Error("KeyboardFunction::函数或函数名不能为空");
		
		var tArgs:Array = null;
		if(funcArgs != null)
			tArgs = getParams(target, funcArgs);
		
		/**
		 * @internal 如果是函数，直接写在代码里的函数
		 */
		if(funcOrName is Function)
		{
			funcOrName.apply(target, tArgs);
		}
		/**
		 * @internal 如果是字符，或写在配置里的字符
		 */
		else if(funcOrName is String)
		{
			var fn:String = funcOrName.toString();
			
			if(fn.indexOf(".") == -1)
			{
				if(target.hasOwnProperty(fn))	
					target[fn].apply(target, tArgs);
			}
			else
			{
				/**	 @internal 	
				 * 	[遍历]访问公共属性或属性公共方法	
				 */
				var fns:Array = fn.split(".");
				var len:int = fns.length;
				var tempView:Object = target;
				
				for(var i:int = 0; i < len; i ++)
				{
					if(tempView.hasOwnProperty(fns[i]))
					{
						tempView = tempView[fns[i]];
					}
					else
					{
						trace("KeyboardFunction.execute::目标对象没有函数 " + funcOrName);
						trace("Error 不存在的属性或方法 [" + fn + "]，请仔细检查函数执行错误原因。");
						return;
					}
				}
				tempView.apply(target, tArgs);
			}
		}
		else
		{
			throw new ArgumentError("funcOrName类型错误。");
		}
	}
	
	/**
	 *	@privat	获取参数 以%开头和%结尾的引用变量
	 * @param viewModel
	 * @param args
	 * @return 返回一个新的数据，源数组不变
	 */		
	private static function getParams(viewModel:Object, args:Array = null):Array
	{
		var argsArr:Array = [];
		if(args != null)
		{
			var len:int = args.length;
			var rep:RegExp = /^%[a-zA-Z0-9_]{0,}%/g;
			
			for(var i:int = 0; i < len; i ++)
			{
				if(args[i] is String && rep.test(args[i].toString()))
				{
					var prop:String = args[i].toString();
					prop = prop.replace(/%/g, "");
					argsArr[i] = viewModel.hasOwnProperty(prop) ? viewModel[prop] : args[i];
				}
				else
				{
					argsArr[i] = args[i];
				}
			}
		}
		
		return argsArr;
	}
}