package flash.net
{
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.utils.ByteArray;
	import flash.utils.NetworkUtil;
	
	//http://help.adobe.com/zh_CN/as3/dev/WS5b3ccc516d4fbf351e63e3d118a9b8f6c0-7ffe.html
	/**
	 * URL 编码变量 URL 编码格式提供了一种在单个文本字符串中表示多个变量（变量名和值对）的方法。
	 * 各变量采用 name=value 格式书写。各个变量（即各个名称-值对）之间用 & 符隔开，
	 * 如下所示：variable1=value1&variable2=value2。这样，便可以将不限数量的变量作为一条消息进行发送。
	 * 
	 * 请求方法 应用程序（例如 AIR 应用程序或 Web 浏览器）将消息（称为 HTTP 请求）发送到 Web 服务器时，
	 * 发送的任何数据都可以使用以下两种方法之一嵌入到请求中 — 这两种请求方法是 GET 和 POST。
	 * 在服务器端，接收请求的程序需要查看相应的请求部分以查找数据，
	 * 因此用于从您的应用程序发送数据的请求方法应与用于在服务器上读取该数据的请求方法匹配。
	 * 
	 *	Server通信支持使用URL变量
	 *  UDP获取或设置Server状态信息
	 * 文件服务器，
	 * 进程控制，及进程输出
	 * 
	 * 1.还没想到文件服务器怎么处理(考虑可以写成控制台程序)
	 * 2.还没想到进程输出怎么处理(延时在处理进程结果)
	 * 
	 * @author Administrator
	 * @playerversion AIR 2
	 */	
	public class SocketServer extends EventDispatcher
	{
		/** TCP	Socket 集合	*/
		protected var clients:Vector.<Socket>;
		/**	TCP Socket	*/
		protected var serverSocket:ServerSocket;
		/**	UDP Socket	*/
		protected var datagramSocket:DatagramSocket;
		
		/**	视图或模型对象	*/
		public var viewModel:Object = null;
		/**	运行错误警告模式	@default false	*/
		public var errorWarningMode:Boolean = false;		
		/**	解析HTTP请求头部信息，分析URL变量 */	
		public var parseHTTPRequest:Boolean = false;	
		
		private var _bytes:ByteArray;
		
		/**
		 *	Socket服务端
		 * 	@param localPort	本地端口
		 */
		public function SocketServer(localPort:int = 2001)
		{
			//TCP
			serverSocket = new ServerSocket();
			serverSocket.addEventListener(Event.CLOSE, onServerCloseEventHandler);
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, onServerConnectEventHandler);
			serverSocket.bind(localPort);
			serverSocket.listen();
			
			//UDP
			datagramSocket = new DatagramSocket();
			datagramSocket.bind(localPort);
			datagramSocket.receive();
			datagramSocket.addEventListener(DatagramSocketDataEvent.DATA, onDatagramSocketDataEventHandler);
			
			_bytes = new ByteArray();
			clients = new Vector.<Socket>();
		}
		
		/**
		 *	关闭套接字服务并停止侦听连接。
		 *  关闭的套接字无法重新打开服务。需应创建一个新的 SocketServer 实例。
		 */		
		public function dispose():void
		{
			serverSocket.removeEventListener(Event.CLOSE, onServerCloseEventHandler);
			serverSocket.removeEventListener(ServerSocketConnectEvent.CONNECT, onServerConnectEventHandler);
			datagramSocket.removeEventListener(DatagramSocketDataEvent.DATA, onDatagramSocketDataEventHandler);
			
			_bytes.clear();
			_bytes = null;
			
			clients = null;
			viewModel = null;
			
			datagramSocket.close();
			datagramSocket = null;
			
			serverSocket.close();
			serverSocket = null;
		}
		
		//系统关闭ServerSocket时处理
		private function onServerCloseEventHandler(e:Event):void
		{
			dispose();
			throw new Error("操作系统关闭了ServerSocket套接字.");
		}
		//TCP Socket 连接事件处理
		private function onServerConnectEventHandler(e:ServerSocketConnectEvent):void
		{
			addTCPSocket(e.socket);
		}
		
		/**
		 *	添加TCP Socket对象 
		 * @param sock
		 */		
		protected function addTCPSocket(sock:Socket):void
		{
			clients.push(sock);
			
			sock.addEventListener(Event.CLOSE, onSocketCloseEventHandler, false, 0, true);
			sock.addEventListener(ProgressEvent.SOCKET_DATA, onSocketDataEventHandler, false, 0, true);
						
			trace("client " + sock.remoteAddress + ":" + sock.remotePort + " connection success.");
		}
		/**
		 *	移除TCP Socket对象 
		 * 	@param sock
		 */		
		protected function removeTCPSocket(sock:Socket):void
		{
			var startIndex:int = clients.indexOf(sock);
			if(startIndex != -1)
				clients.splice(startIndex, 1);
			
			trace("client " + sock.remoteAddress + ":" + sock.remotePort + " disconnection.");
			
			sock.removeEventListener(Event.CLOSE, onSocketCloseEventHandler);
			sock.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketDataEventHandler);
		}
		
		//client socket close event handler.
		private function onSocketCloseEventHandler(e:Event):void
		{
			removeTCPSocket(e.target as Socket);
		}
		//client socket data event handler.
		private function onSocketDataEventHandler(e:ProgressEvent):void
		{
			//analyseSocketData(e.target as Socket);
			parseClientData(e.target as Socket);
		}
		//UDP Socket 数据事件
		private function onDatagramSocketDataEventHandler(e:DatagramSocketDataEvent):void
		{
			parseClientData(e);
		}
		
		/**
		 *	发送数据至客户端 
		 * @param client
		 * @param data
		 */		
		public function sendToClient(client:Object, data:String):void
		{
			if(client == null || data == null)	return;
			
			_bytes.clear();
			_bytes.writeUTFBytes(decodeURIComponent(data));
			
			if(client is Socket)
			{
				client.writeBytes(_bytes);
				client.flush();
			}
			else
			{
				datagramSocket.send(_bytes, 0, 0, client.srcAddress, client.srcPort);
			}
		}
		
		/**
		 *	解析客户端数据 
		 * 	@param client
		 */		
		protected function parseClientData(client:Object):void
		{
			if(client == null)	return;
			
			var variables:URLVariables;
			var source:String = client is Socket ? client.readUTFBytes(client.bytesAvailable) : client.data.readUTFBytes(client.data.bytesAvailable);
			
			/**
			 * @internal	解析HTTP请求头部信息
			 */
			if(parseHTTPRequest && client is Socket)
			{
				
				return;
			}
			
			try
			{
				variables = new URLVariables(source);
			}
			catch(error:Error)
			{
				sendToClient(client, "funcName=serverReturnResult&args=please send url variables&code=0x01");
				
				trace("源 [" + source + "] 参数必须是包含名称/值对的 URL 编码的查询字符串.");
				return;
			}
			
			parseSystemURLVariables(variables, client);
		}
		
		
		/**
		 *	解析系统变量，系统执行方法或函数
		 * 	@param variables
		 */		
		protected function parseSystemURLVariables(variables:URLVariables, client:Object):void
		{
			var func:String = variables.hasOwnProperty("funcName") ? variables.funcName : variables.hasOwnProperty("func") ? variables.func : null;
			if(func == null)	return;
			
			switch(func)
			{
				case "getOnline":
					break;
				
				/**
				 * @internal	获取Demo配置
				 */
				case "getDemoConfig":
					if(viewModel == null || client == null)	return;
					if(viewModel.hasOwnProperty("demoName") && viewModel.demoName == variables.args)
					{
						var remoteAddress:String = client is Socket ? client.remoteAddress : client.srcAddress;
						var localAddress:String = NetworkUtil.getLANAddress(remoteAddress);
						
						var config:URLVariables = new URLVariables();
						config.decode("address=" + localAddress + "&port=" + serverSocket.localPort + "&demoName=" + viewModel.demoName);
						if(variables.hasOwnProperty("resultCallBack"))
							config.funcName = variables.resultCallBack;
						
						sendToClient(client, config.toString());
					}
					break;
				
				/**
				 * @internal	获取Server信息
				 */
				case "getServerInfo":
					if(client == null)	return;
					var info:String = NetworkUtil.getLocalAddressInfo().toString();
					info = info.replace(/&/g, "|");
					
					if(variables.hasOwnProperty("resultCallBack"))
						info = "funcName=" + variables.resultCallBack + "&" + info;
					
					sendToClient(client, info);
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
					parseUserURLVariables(variables, client);
			}
		}
		
		/**
		 *	解析用户变量，客户端执行方法或函数
		 * 	@param variables
		 */		
		protected function parseUserURLVariables(variables:URLVariables, client:Object):void
		{
			if(viewModel == null)		return;
			
			var func:String = variables.hasOwnProperty("funcName") ? variables.funcName : variables.hasOwnProperty("func") ? variables.func : null;
			if(func == null)	return;
			
			var args:Array = variables.hasOwnProperty("args") ? variables.args.split(",") : null;
			
			/**
			 * @internal	如果客户端需要结果回调，则将客户端回调函数及客户端对象传递给要调用的函数
			 */
			if(variables.hasOwnProperty("resultCallBack"))
				args = args == null ? [variables.resultCallBack, client] : args.concat(variables.resultCallBack, client);
			
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