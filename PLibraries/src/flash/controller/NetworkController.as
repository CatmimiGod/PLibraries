package flash.controller
{
	import flash.events.ProgressEvent;
	import flash.net.SocketClient;
	import flash.net.URLVariables;
	import flash.utils.Base64;
	
	/**
	 *  网络控制公共类，<b>用于控制端或被控制客户端</b>，如需增加复杂分析功能，请继承此类。 <br>
	 * 	<br/>URLVariables参数协议：<br/>
	 * 	1.参数属性demoName，值为构造函数config.demoName的值；<br/>
	 * 	2.参数属性funcName，值为构造函数viewMode对象的方法，值可带参数，以":"分隔方法与参数，以","分隔多参数，<b>参数类型为数字和字符不可为复杂数据类型</b>；<br/>
	 * 
	 * <br/>发送端发送变量，例：<br/>
	 * <li>demoName=DN&amp;funcName=play</li>
	 * <li>demoName=DN&amp;funcName=gotoAndStop:5[不建议此格式]</li>
	 * <li>demoName=DN&amp;funcName=setSize&amp;args=100,200</li>
	 */
	public final class NetworkController
	{
		/**	错误警告模式	@default false	*/
		public var errorWarningMode:Boolean = false;
		
		/** 是否拆分参数 */
		public var isArgumentSplit:Boolean = true;
		
		private var _config:Object;
		
		/**	视图或模型对象	*/
		protected var _viewModel:Object;
		
		/** Socket Client.*/
		protected var _socket:SocketClient;
		
		/**
		 *	Constructor.<br/>
		 * 
		 * @param vieMode:Object	视图或模型对象
		 * @param config:Object		用于NetWork参数配置，包括属性demoName,port,address
		 * 
		 * @throws ArgumentError 参数不能为空
		 * @throws ArgumentError 参数config缺少必要属性[demoName,port,address] 
		 * 
		 * <listing version="3.0">
		 * Example:
		 * //Config
		 * &lt;data&gt;
		 * 	&lt;network&gt;
		 * 		&lt;demoName&gt;custom &lt;/demoName&gt;
		 * 		&lt;port&gt;2000&lt;/port&gt;
		 * 		&lt;address&gt;127.0.0.1&lt;/address&gt;
		 * 	&lt;/network&gt;
		 * &lt;/data>
		 * 
		 *  //添加网络控制器
		 *	var networkController:NetworkController = new NetworkController(this, _config.network);
		 * 	//向控制端发送
		 *  networkController.sendURLVariables(byteArray);
		 * </listing>
		 * 
		 */		
		public function NetworkController(viewModel:Object, config:Object)
		{
			if(viewModel == null || config == null)
				throw new ArgumentError("NetworkController::viewModel参数不能为空");
			
			if(config.hasOwnProperty("port") && config.hasOwnProperty("address"))
			{
				_config = config;
				_viewModel = viewModel;
				
				_socket = new SocketClient(_config.address, int(_config.port));
				_socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketEventHandler);
			}
			else
			{
				throw new ArgumentError("NetworkController::参数config缺少必要属性[port,address].");
			}
		}
		
		public function get demoName():String{	return _config.demoName;	}
		public function get address():String{	return _config.address;		}
		public function get port():int{		return int(_config.port);	}
		
		/**
		 *	清理。清理后请将此对象设为null
		 */
		public function dispose():void
		{
			if(_socket)
			{
				_socket.enabledReconnect = false;
				_socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketEventHandler);
				
				if(_socket.connected)
					_socket.close();
				
				_socket = null;
			}
			
			_config = null;
			_viewModel = null;		
		}
		
		/**
		 *	向数据发送端，发送URLVariables数据。 
		 * @param variables:URLVariables
		 * @throws ArgumentError URLVariables参数缺少必要属性[funcName]，<b>且要访问的函数必须是public类型</b>
		 * 
		 * @return	如果发送成功则返回true，发送失败则返回false
		 */		
		public function sendURLVariables(variables:URLVariables):Boolean
		{
			if(_socket && _socket.connected)
			{
				if(variables.hasOwnProperty("funcName") || variables.hasOwnProperty("functionName") || variables.hasOwnProperty("func"))
				{
					if((!variables.hasOwnProperty("demoName")) && _config.hasOwnProperty("demoName") && _config.demoName != "" && _config.demoName != "null")
						variables.demoName = _config.demoName;
					
					_socket.writeUTFBytes(decodeURIComponent(variables.toString()));
					_socket.flush();
					return true;
				}
				else
				{
					throw new ArgumentError("NetworkController::sendURLVariables()参数缺少必要属性[funcName].");
					return false;
				}
			}
			else
			{
				trace("NetworkController::sendURLVariables() 发送失败.");
				return false;
			}
		}
		
		//网络控制
		private function onSocketEventHandler(e:ProgressEvent):void
		{
			var data:String = _socket.readUTFBytes(_socket.bytesAvailable);
			var variables:URLVariables = new URLVariables();
			
			try
			{
				variables.decode(data);
			}
			catch(e:Error)
			{
				traceError("NetworkController::URLVariables << " + data + " >> 解析错误。");
			}
			
			if(variables.hasOwnProperty("demoName"))
			{
				if(_config.hasOwnProperty("demoName") && _config.demoName != "" && _config.demoName != "null" && variables.demoName == _config.demoName)
					analyseURLVariables(variables);
			}
			else
			{
				analyseURLVariables(variables);
			}
		}
		
		/**
		 *	分析URL变量数据，此方法可继承或重写。
		 *	@params variables:URLVariables	URL变量参数。 
		 */
		protected function analyseURLVariables(variables:URLVariables):void
		{
			//trace("analyseURLVariables::", decodeURIComponent(variables.toString()));
			
			//demoName=DN&funcName=playVideoIndex&args=1
			if(variables.hasOwnProperty("funcName") || variables.hasOwnProperty("functionName") || variables.hasOwnProperty("func"))
			{
				//Format: funcName=func&args=arg0,arg1&encode=base64
				var funcName:String = variables.hasOwnProperty("funcName") ? variables.funcName : variables.hasOwnProperty("func") ? variables.func : variables.functionName;
				
				if(!isArgumentSplit)
				{
					_viewModel[funcName](variables.args);
					return ;
				}
				
				var fn:String;
				var args:Array;
				
				if(variables.hasOwnProperty("args") || variables.hasOwnProperty("arguments"))
				{
					fn = funcName;
					var arguments:String = variables.hasOwnProperty("args") ? variables.args : variables.arguments;
					args = (variables.hasOwnProperty("encode") && variables.encode == "base64") ? [Base64.decode(arguments)] : arguments.split(",");
				}
				else
				{
					//[不建议使用此格式]
					var arr:Array = funcName.split(":");
						
					fn = arr[0];
					args = arr.length > 1 ? arr[1].split(",") : null;
				}
				
				//不应在此catch错误 2016.01.16
				//try
				//{
					/**	 @internal 	直接访问公共方法	*/
					if(fn.indexOf(".") == -1)
					{
						_viewModel[fn].apply(_viewModel, args);
					}
					else
					{
						/**	 @internal 	[遍历]访问公共属性或属性公共方法	*/
						//Format: funcName=obj.func&args=arg0,arg1&encode=base64
						var fns:Array = fn.split(".");
						var len:int = fns.length;
						var tempView:Object = _viewModel;
						
						for(var i:int = 0; i < len; i ++)
						{
							if(tempView.hasOwnProperty(fns[i]))
							{
								tempView = tempView[fns[i]];
							}
							else
							{
								traceError("Error 不存在的属性或方法 [" + fn + "]，请仔细检查函数执行错误原因。");
								return;
							}
						}
						
						tempView.apply(_viewModel, args);
					}
				//}
				//catch(e:Error)
				//{
					//traceError(e.message + "\nError: 函数: " + fn + ", 参数: [" + (args == null ? "无" : args) + "] 执行错误，请仔细检查函数执行错误原因。 ErrorID:" + e.errorID);
				//}
			}
			else
			{
				trace("NetworkController::analyseURLVariables() 对象属性funcName不存在.");
			}
		}
		
		/**
		 *	跟踪或输出错误 
		 * @param message
		 */		
		protected function traceError(message:String):void
		{
			trace(message);
			
			if(errorWarningMode)	
				throw new Error(message);
		}
		
	}
}