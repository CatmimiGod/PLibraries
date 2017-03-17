package flash.net.http
{
	import flash.utils.ByteArray;

	/**
	 *	HTTP响应对象 
	 * @author Administrator
	 * 
	 * 常见状态代码、状态描述的说明如下。
	 * •200 OK：客户端请求成功。
	 * •400 Bad Request：客户端请求有语法错误，不能被服务器所理解。
	 * •401 Unauthorized：请求未经授权，这个状态代码必须和WWW-Authenticate报头域一起使用。
	 * •403 Forbidden：服务器收到请求，但是拒绝提供服务。
	 * •404 Not Found：请求资源不存在，举个例子：输入了错误的URL。
	 * •500 Internal Server Error：服务器发生不可预期的错误。
	 * •503 Server Unavailable：服务器当前不能处理客户端的请求，一段时间后可能恢复正常，举个例子：HTTP/1.1 200 OK（CRLF）。
	 * 
	 */	
	public final class HTTPResponse
	{
		/**	HTTP版本	*/
		public static var HTTP_VERSION:String = "HTTP/1.1";
		
		/**	服务器版本	*/
		public static var SERVER_VERSION:String = "AIR File Provider Server v0.1 bate";
				
		/**	认证类型	*/
		public var authenticateType:String = "Basic realm=\"Basic Auth Test!\"";
		
		/**	内容类型	@default text/html;charset=ISO-8859-1	*/
		public var contentType:String = "text/html;charset=ISO-8859-1";
		
		/**包含将随 URL 响应一起传输的正文数据*/
		public var body:ByteArray = new ByteArray();
		
		/**	要追加到 HTTP 响应的 HTTP 响应标头的数组。	*/
		public var responseHeaders:Array;
		
		/**	响应状态码及状态描述	*/
		public var status:String;
		
		
		/**
		 * http://www.cnblogs.com/loveyakamoz/archive/2011/07/22/2113614.html
		 *	创建 HTTPResponse 对象 
		 * 	@param stateCode
		 */		
		public function HTTPResponse(status:String = "200 OK")
		{
			this.status = status;
		}
		
		public function toBytes():ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(toString());
			bytes.writeBytes(body);
			bytes.position = 0;
			
			return bytes;
		}
		
		public function toString():String
		{
			//＜status-line＞	状态行
			//＜headers＞		响应头(Response Header)		
			//＜blank line＞			
			//[＜response-body＞]	响应正文
			
			var response:String = "";
			var statusLine:String = HTTP_VERSION + " " + status + "\r\n";
			
			response += statusLine;
			response += new HTTPResponseHeader("Server", SERVER_VERSION);
			response += new HTTPResponseHeader("Date", new Date().toString());
			
			if(authenticateType != null)
				response += new HTTPResponseHeader("WWW-Authenticate", authenticateType);
			
			if(responseHeaders != null)
			{
				var len:uint = responseHeaders.length;
				for(var i:int = 0; i < len; i ++)
					response += responseHeaders[i];
			}
			
			//response += new HTTPResponseHeader("Connection", "Close");
			response += new HTTPResponseHeader("Content-Type", contentType);
			response += new HTTPResponseHeader("Content-Length", body.length.toString());
			response += "\r\n\r\n";
			
			return response;
		}
		
	}
}