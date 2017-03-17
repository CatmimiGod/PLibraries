package flash.net
{
	import flash.net.Socket;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 *	Socket Client 
	 * @author huangm
	 */	
	public final class SocketClient extends Socket
	{
		/**	断开连接后，重复连接 */		
		public var enabledReconnect:Boolean = true;
		
		/**	断开后延时多长时间（秒）连接， 当enabledReconnect为true时，此参数有效 */		
		public var interval:Number = 1;
		
		/**	 socket连接成功后发送的描述信息,default:null */		
		public var description:String = null;
		
		private var _host:String = null;
		private var _port:int = 0;
		
		private var _timerID:uint;
		
		/**
		 *	 Constructor.
		 */		
		public function SocketClient(host:String=null, port:int=0, description:String = null)
		{
			_host = host;
			_port = port;
			this.description = description;
			
			super(host, port);
		}
		
		/**
		 * 将套接字连接到指定的主机和端口。
		 * 
		 * @param host:String  要连接到的主机的名称或 IP 地址。@default null
		 * @param port:int 要连接到的端口号。
		 */ 
		override public function connect(host:String, port:int):void
		{
			_host = host;
			_port = port;
			
			configureListeners();
			super.connect(host, port);
		}
		
		/**
		 *	@inheritDoc.
		 */		
		override public function close():void
		{
			clearTimeout(_timerID);
			enabledReconnect = false;
			removeConfigureListeners();
			
			super.close();
		}
		
		/**
		 * 重新连接Socket服务器。当isReconnect为true, Socket连接中断时，此方法有效。
		 */
		protected function reconnectionSocket():void
		{
			if(!super.connected && enabledReconnect)
				_timerID = setTimeout(super.connect, this.interval * 1000, _host, _port);
			else
				clearTimeout(_timerID);
		}
		
		/**
		 * @private
		 * 事件监听
		 */ 
		private function configureListeners():void
		{
			super.addEventListener(Event.CLOSE, onSocketEventHandler, false, 0, true);
			super.addEventListener(Event.CONNECT, onSocketEventHandler, false, 0, true);
			super.addEventListener(IOErrorEvent.IO_ERROR, onSocketEventHandler, false, 0, true);
		}
		/**
		 * @private
		 * 移除事件监听
		 */ 
		private function removeConfigureListeners():void
		{
			super.removeEventListener(Event.CLOSE, onSocketEventHandler);
			super.removeEventListener(Event.CONNECT, onSocketEventHandler);
			super.removeEventListener(IOErrorEvent.IO_ERROR, onSocketEventHandler);
		}
		
		private function onSocketEventHandler(e:Event):void
		{
			switch(e.type)
			{
				case Event.CONNECT:
					if(description)
					{
						super.writeUTFBytes(description);
						super.flush();
					}
					break;
				
				case Event.CLOSE:
				case IOErrorEvent.IO_ERROR:
					reconnectionSocket();
					break;
				
				case SecurityErrorEvent.SECURITY_ERROR:
					break;
				
				case ProgressEvent.SOCKET_DATA:
					break;
			}
		}
		
		
	}
}