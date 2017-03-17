package flash.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.net.http.HTTPResponse;
	import flash.net.http.HTTPResponseHeader;
	import flash.utils.ByteArray;
	import flash.utils.RegExpUtil;
	
	/**
	 *	文件供给服务
	 * @author Administrator
	 */	
	public class FileProviderServer extends EventDispatcher
	{
		protected var serverSocket:ServerSocket;
		
		protected var response:HTTPResponse;
		
		private var _bytes:ByteArray;
		
		/**
		 * Constructor.
		 * @param localPort
		 */
		public function FileProviderServer(localPort:int = 2002)
		{
			//TCP
			serverSocket = new ServerSocket();
			serverSocket.addEventListener(Event.CLOSE, onServerCloseEventHandler);
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, onServerConnectEventHandler);
			serverSocket.bind(localPort);
			serverSocket.listen();
			
			_bytes = new ByteArray();
			response = new HTTPResponse();
		}
		
		/**
		 *	关闭套接字服务并停止侦听连接。
		 *  关闭的套接字无法重新打开服务。需应创建一个新的 SocketServer 实例。
		 */		
		public function dispose():void
		{
			serverSocket.removeEventListener(Event.CLOSE, onServerCloseEventHandler);
			serverSocket.removeEventListener(ServerSocketConnectEvent.CONNECT, onServerConnectEventHandler);
			
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
			var sock:Socket = e.socket;
			sock.addEventListener(Event.CLOSE, onSocketCloseEventHandler, false, 0, true);
			sock.addEventListener(ProgressEvent.SOCKET_DATA, onSocketDataEventHandler, false, 0, true);
		}
		
		//Socket Close Event Handler
		private function onSocketCloseEventHandler(e:Event):void
		{
			closeSocket(e.target as Socket);
		}
		//Socket Data Event Handler.
		private function onSocketDataEventHandler(e:ProgressEvent):void
		{
			parseHTTPHeader(e.target as Socket);
		}
		
		/**
		 *	断开客户端连接 
		 * @param sock
		 */		
		protected function closeSocket(sock:Socket):void
		{
			if(sock == null)	return;
			
			sock.removeEventListener(Event.CLOSE, onSocketCloseEventHandler);
			sock.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketDataEventHandler);
			
			if(sock.connected)
				sock.close();
			
			sock = null;
		}
		
		
		/**
		 *	 解析HTTP头部信息 
		 *	@param sock
		 */		
		protected function parseHTTPHeader(sock:Socket):void
		{
			var header:Array = sock.readUTFBytes(sock.bytesAvailable).replace(/\s*$/g, "").split("\r\n");
			
			trace(header.length);
			var len:uint = header.length;
			for(var i:int = 0; i < len; i ++)
				trace(header[i]);
			
			
			if(len < 2 || !RegExpUtil.HTTP_HEADER.test(header[0]))
			{
				closeSocket(sock);
				return;
			}
			
			trace("Request Pass...");
			var result:Object = RegExpUtil.HTTP_HEADER.exec(header[0]);
			trace(result[0], ">>>>", result[1], ">>", result[2], ">>", result[3]);
			
			var uri:String = result[2];
			
			//Write
			response.status = "401 Unauthorized";
			response.body.clear();
			response.body.writeMultiByte(get404Error(), "GB2312");
			
			trace("\r\n---------------------------------", response);
			sock.writeBytes(response.toBytes());
			sock.flush();
		}
		
		
		/**
		 *	 
		 * @param webroot
		 * @param folder
		 * @return 
		 */
		private static function getFolderList(webroot:String, folder:String = "/"):String
		{
			var dir:String = "/" + folder.substring(webroot.length);
			
			var html:String = "<html><body><p><h3>Directory Listing For " + dir + "</h3></p><hr/><ul>\n";
			
			var file:File = new File(folder);
			if(file.exists)
			{
				if(folder != webroot)
				{
					var len:int = folder.lastIndexOf("/") - webroot.length - 1;
				}
			}
			
			return "";
		}
		
		private static function get404Error():String
		{
			var html:String = "";
			html += "<html><body><p><h1>404</h1></p>\n";
			html += "<a href=\"\\\">返回主面</a>\r\n";
			html += "</ul></body></html>";
			
			return html;
		}
	}
}