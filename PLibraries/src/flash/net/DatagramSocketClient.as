package flash.net
{
	import flash.events.DatagramSocketDataEvent;
	import flash.utils.ByteArray;

	/**
	 *	UDP 配置  ???? 2016.01.04使用UDP通信？TCP通信
	 * 	@author Administrator
	 */	
	public final class DatagramSocketClient
	{
		private var _bytes:ByteArray;
		private var _socket:DatagramSocket;
		
		/**	视图或模型对象	*/
		public var viewModel:Object = null;
		/**	运行错误警告模式	@default false	*/
		public var errorWarningMode:Boolean = false;		
		
		
		/**
		 *	UDP客户端 
		 * 	@param localPort
		 */		
		public function DatagramSocketClient(localPort:int = 2200)
		{
			_socket = new DatagramSocket();
			_socket.bind(localPort);
			_socket.receive();
			
			_bytes = new ByteArray();
			_socket.addEventListener(DatagramSocketDataEvent.DATA, onDatagramSocketDataHandler);
		}
		
		/**
		 *	关闭套接字。
		 * 	此套接字从远程计算机断开并从本地计算机解除绑定。不能重复使用关闭的套接字。 
		 */		
		public function dispose():void
		{
			_socket.removeEventListener(DatagramSocketDataEvent.DATA, onDatagramSocketDataHandler);
			
			_bytes.clear();
			_bytes = null;
			
			_socket.close();
			_socket = null;
			
			viewModel = null;
		}
		
		private function onDatagramSocketDataHandler(e:DatagramSocketDataEvent):void
		{
			var variables:URLVariables;
			var source:String = e.data.readUTFBytes(e.data.bytesAvailable);
			trace(source, e.srcAddress, e.srcPort);
			
			try
			{
				variables = new URLVariables(source);
			}
			catch(error:Error)
			{
				_bytes.clear();
				_bytes.writeUTFBytes("funcName=serverReturnResult&address=" + _socket.localAddress + ":" + _socket.localPort +"&args=please send url variables.");
				
				_socket.send(_bytes, 0, 0, e.srcAddress, e.srcPort);
				trace("源参数必须是包含名称/值对的 URL 编码的查询字符串.");
				return;
			}
			
			parseSystemURLVariables(variables, e.srcAddress, e.srcPort);
		}
		
		/**
		 * 解析系统变量，系统执行方法或函数
		 * @param variables
		 * @param remoteAddress
		 * @param remotePort
		 */
		protected function parseSystemURLVariables(variables:URLVariables, remoteAddress:String, remotePort:int):void
		{
			var func:String = variables.hasOwnProperty("funcName") ? variables.funcName : variables.hasOwnProperty("func") ? variables.func : null;
			if(func == null)	return;
			
			switch(func)
			{
				case "getOnline":
					_bytes.clear();
					_bytes.writeUTFBytes("funcName=getOnlineResult&args=" + _socket.localAddress + ":" + _socket.localPort);
					
					_socket.send(_bytes, 0, 0, remoteAddress, remotePort);
					break;
				
				case "getClients":
					break;
				
				case "runProcess":
					break;
				
				case "Reserved_0":
					break;
				
				case "Reserved_1":
					break;
				
				default:
					parseUserURLVariables(variables);
			}
		}
		
		/**
		 *	解析用户变量，客户端执行方法或函数
		 * 	@param variables
		 */		
		protected function parseUserURLVariables(variables:URLVariables):void
		{
			if(viewModel == null)		return;
			
			var func:String = variables.hasOwnProperty("funcName") ? variables.funcName : variables.hasOwnProperty("func") ? variables.func : null;
			if(func == null)	return;
			
			var args:Array = variables.hasOwnProperty("args") ? variables.args.split(",") : null;
			
			try
			{
				if(func.indexOf(".") == -1)
				{
					/**	 @internal 	直接访问公共方法	*/
					viewModel[func].apply(viewModel, args);
				}
				else
				{
					/**	 @internal 	[遍历]访问公共属性或属性公共方法	*/
					var fns:Array = func.split(".");
					var len:int = fns.length;
					var tempView:Object = viewModel;
					
					for(var i:int = 0; i < len; i ++)
					{
						if(tempView.hasOwnProperty(fns[i]))
						{
							tempView = tempView[fns[i]];
						}
						else
						{
							traceError("Error 不存在的属性或方法 [" + func + "]，请仔细检查函数执行错误原因。");
							return;
						}
					}
					
					tempView.apply(viewModel, args);
				}
			}
			catch(e:Error)
			{
				traceError(e.message + "\nError: 函数: " + func + ", 参数: [" + (args == null ? "无" : args) + "] 执行错误，请仔细检查函数执行错误原因。 ErrorID:" + e.errorID);
			}
		}
		
		/**
		 *	跟踪或输出错误 
		 * @param message
		 */		
		protected function traceError(message:String):void
		{
			trace(message);
			if(errorWarningMode)	throw new Error(message);
		}
		
	}
}