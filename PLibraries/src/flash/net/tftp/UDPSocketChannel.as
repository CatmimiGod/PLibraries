/**
 * UDP单通道数据传输，针对大数据对象传输通道
 * 跟据TFTP协议(或自定义升级)完成数据传输
 * TFTP协议参考：http://zh.wikipedia.org/wiki/TFTP
 */
package flash.net.tftp
{
	import flash.errors.IllegalOperationError;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.DatagramSocket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**	数据发送/接收产生进度时调度  */	
	[Event(name="ProgressEvent.PROGRESS", type="flash.events.Event")]
	
	/**	I/O错误 */	
	[Event(name="IOErrorEvent.IO_ERROR", type="flash.events.Event")]
	
	/**	数据块发送/接收超时时调度 */	
	[Event(name="SocketChannelEvent.TIMEOUT", type="flash.net.tftp.SocketChannelEvent")]
	
	/**	数据发送完成时调度 */	
	[Event(name="SocketChannelEvent.SEND_COMPLETE", type="flash.net.tftp.SocketChannelEvent")]
	
	/**	数据接收完成时调度 */	
	[Event(name="SocketChannelEvent.RECEIVE_COMPLETE", type="flash.net.tftp.SocketChannelEvent")]
	
	
	/**
	 *	UDP大量字节数据单通道传输对象 
	 * 	@author Huangmin
	 */	
	public class UDPSocketChannel extends EventDispatcher
	{
		//块索引大小
		private var _blockIndex:int = -1;
		//块字节大小
		private var _blockSize:uint = 10 * 1024;
		//块字节对象
		private var _blockBytes:ByteArray;
		//操作码
		private var _opcode:uint;
		private var _data:ByteArray;
		private var _totalSize:uint;
		
		private var _localPort:int = 2001;
		private var _udp:DatagramSocket;
		
		private var _timer:Timer;
		private var _timeout:uint = 3;
		
		private var _remotePort:int = 0;
		private var _remoteAddress:String = null;
		
		
		/**
		 *	Constructor. 
		 * 	单通道数据传输(UDP)对象。
		 * 	@param bindLocalPort:int	绑定到本地端口号，用于接收数据端口；建议端口大小1024
		 */		
		public function UDPSocketChannel(bindLocalPort:int = 2001)
		{
			_localPort = bindLocalPort > 0 ? bindLocalPort : _localPort;
			
			_timer = new Timer(1000, _timeout);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerCompleteHandler, false, 0, true);
			
			createSocket();
		}
		
		/**	创建UDP Socket对象 */		
		protected function createSocket():void
		{
			if(DatagramSocket.isSupported && _udp == null)
			{
				_udp = new DatagramSocket();
				_udp.bind(_localPort);
				_udp.receive();
				
				_udp.addEventListener(Event.CLOSE, onCloseHandler, false, 0, true);
				_udp.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler, false, 0, true);
				_udp.addEventListener(DatagramSocketDataEvent.DATA, onSocketDataHandler, false, 0, true);
			}
			else
			{
				throw new Error("UDPSocketChannel创建失败。");
			}
		}
		
		private var _requestEvent:SocketChannelEvent;
		private var _progressEvent:ProgressEvent;
		private var _completeEvent:SocketChannelEvent;
		private var _duration:Number;
		
		
		/**	清除通道数据	*/	
		protected function clear():void
		{
			_remotePort = 0;
			_remoteAddress = null;
			
			_duration = 0;
			_totalSize = 0;
			_blockIndex = -1;
			
			if(_data != null)		_data.clear();
			_data = null;
			
			if(_blockBytes != null)		_blockBytes.clear();
			_blockBytes = null;			
			
			_requestEvent = null;
			_progressEvent = null;
			_completeEvent = null;
		}
		
		/**	销毁并清理传输通道 */		
		public function dispose():void
		{
			clear();
			
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerCompleteHandler);			
			_timer = null;
			
			if(_udp != null)
			{ 
				_udp.removeEventListener(Event.CLOSE, onCloseHandler);
				_udp.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
				_udp.removeEventListener(DatagramSocketDataEvent.DATA, onSocketDataHandler);
				
				if(_udp.connected)	_udp.close();
				_udp = null;
			}
		}
		
		/**
		 * 发送大量字节数据 <br>
		 * 数据发送请求包格式
		 * 
		 * @param bytes
		 * @param remoteAddress
		 * @param remotePort
		 * 
		 * @throws IllegalOperationError 数据正在传输过程中，不可操作此方法。
		 * @throws ArgumentError <b>bytes字节大小超出块字节(blockSize) * 最多发送次数(0xFFFFF)</b>
		 * @throws RangeError 当 port 小于 1 或大于 65535 时，会发生此错误。
		 * @throws ArgumentError 如果远程主机IP地址格式不正确的 IP 地址。
		 * 
		 */
		public function send(bytes:ByteArray, remoteAddress:String, remotePort:int):void
		{
			if(_blockIndex == -1)
			{
				/**	@internal	先计算分块次数与总体字节大小是否在范围内*/
				if(Math.ceil(bytes.length / _blockSize) >= 0xFFFF - 1)
					throw new ArgumentError("UDPSocketChannel::bytes字节大小超出 字节块大小(blockSize) * 字节块总数量(0xFFFF)	\n\t\t\t可修改字节块大小(blockSize)值，或升级传输协议字节块总量为32位无符号整数(0xFFFFFF)");
				
				_data = bytes;
				_blockIndex = 0;
				_totalSize = _data.length;
				
				_remotePort = remotePort;
				_remoteAddress = remoteAddress;
				
				//创建一个字节数据发送包				
				_blockBytes = TFTP.createRequestPacket(TFTP.OPCODE_WRQ, "null", "octet", {blockSize:_blockSize, timeout:_timeout, totalSize:bytes.length});
				_udp.send(_blockBytes, 0, 0, _remoteAddress, _remotePort);
				
				_duration = getTimer();	
				_timer.start();
			}
			else
				throw new IllegalOperationError("UDPSocketChannel::数据正在传输不可操作send。");
		}
		
		/**
		 *	中断传输过程，并清除通道数据 (留着未来需要时在开发)
		 */		
		public function interrupt():void
		{			
		}
		
		/**
		 *	分析数据 
		 * @param data
		 */		
		protected function analyseByteArray(data:ByteArray):void
		{
			if(data.length < 4)	return;			
			_opcode = data.readUnsignedShort();		//操作码
			//trace("OPCODE:: 0x" + _opcode.toString(16));
			
			switch(_opcode)
			{
				//Read
				case 0x0001:					
					break;
				
				//Write
				case 0x0002:
					if(_blockIndex >= 0)	return;
					
					var result:Object = TFTP.parseRequestPacket(data);
					if(result.hasOwnProperty("mode") && result.mode == TFTP.MODE_OCTET)
					{
						timeout = uint(result.timeout);
						_totalSize = uint(result.totalSize);
						_blockSize = uint(result.blockSize);
						
						_requestEvent = new SocketChannelEvent(SocketChannelEvent.REQUEST, false, true, _opcode, _blockIndex);
						this.dispatchEvent(_requestEvent);
						
						/** @internal	 开始准备接收数据，回应第一个ACK包	*/
						if(!_requestEvent.isDefaultPrevented())
						{
							_blockIndex = 0;	//开始准备接收数据
							_data = new ByteArray();
							
							//创建第一个应答包		准备接收数据
							_blockBytes = TFTP.createACKPacket(_blockIndex);
							_udp.send(_blockBytes, 0, 0, _remoteAddress, _remotePort);
							
							_duration = getTimer();
							_timer.start();
						}
					}
					break;
				
				//data
				case 0x0003:
					_blockIndex = data.readUnsignedShort();	//读取索引块
					_data.writeBytes(data, 4);
					//trace("ByteArray Length::", _data.length);
					
					//数据接收进度事件
					_progressEvent = new ProgressEvent(ProgressEvent.PROGRESS, false, false, _data.length,  _totalSize);
					this.dispatchEvent(_progressEvent);
					
					/** @internal	 发送ACK包，请求下一个数据块	*/
					if(_data.length < _totalSize)
					{
						_blockBytes = TFTP.createACKPacket( ++ _blockIndex );	
						_udp.send(_blockBytes, 0, 0, _remoteAddress, _remotePort);
						
						_timer.reset();
						_timer.start();
					}
					
					/** @internal 	数据接收完成了	*/
					if(_progressEvent.bytesLoaded == _progressEvent.bytesTotal)
					{
						_timer.reset();
						trace("数据接收完成。");
						
						_completeEvent = new SocketChannelEvent(SocketChannelEvent.RECEIVE_COMPLETE, false, true, _opcode, _blockIndex, _data, -1, getTimer() - _duration);
						this.dispatchEvent(_completeEvent);
						
						if(!_completeEvent.isDefaultPrevented())
							clear();
					}
					break;
				
				//ACK
				case 0x0004:
					/** @internal	 读取对方需要的数据索引块，并发送		*/
					_blockIndex = data.readUnsignedShort();		
					_blockBytes = TFTP.createDataPacket(_data, _blockIndex, _blockSize);
					if(_blockBytes.length > 0)
					{
						_udp.send(_blockBytes, 0, 0, _remoteAddress, _remotePort);
						
						_timer.reset();
						_timer.start();
					}
					
					//数据发送进度事件
					_progressEvent = new ProgressEvent(ProgressEvent.PROGRESS, false, false, _blockIndex * _blockSize + _blockBytes.length - 4, _totalSize);
					this.dispatchEvent(_progressEvent);
					
					if(_progressEvent.bytesLoaded == _progressEvent.bytesTotal)
					{
						_timer.reset();
						trace("数据发送完成");
						
						_completeEvent = new SocketChannelEvent(SocketChannelEvent.SEND_COMPLETE, false, true, _opcode, _blockIndex, _data, -1, getTimer() - _duration);
						this.dispatchEvent(_completeEvent);
						
						if(!_completeEvent.isDefaultPrevented())
							clear();
					}
					break;
				
				//Error
				case 0x0005:
					break;
				
				//Interrupt	对方中断传输
				case 0x0007:
					break;
			}
		}
		
		//UDP接收到数据后处理
		private function onSocketDataHandler(e:DatagramSocketDataEvent):void
		{
			//if(!_udp.connected)
				//_udp.connect(e.srcAddress, e.srcPort);
			
			if(_remoteAddress == null || _remotePort == 0)
			{
				_remotePort = e.srcPort;
				_remoteAddress = e.srcAddress;
			}
			
			var bytes:ByteArray = e.data;
			analyseByteArray(bytes);
		}
		//系统关闭UDP时处理
		private function onCloseHandler(e:Event):void
		{
			dispose();
		}
		//IOError
		private function onIOErrorHandler(e:IOErrorEvent):void
		{
			this.dispatchEvent(e);
		}
		
		//超时
		private function onTimerCompleteHandler(e:TimerEvent):void
		{
			_timer.reset();
			
			var timeoutEvent:SocketChannelEvent = new SocketChannelEvent(SocketChannelEvent.TIMEOUT, false, true, _opcode, _blockIndex, null);
			this.dispatchEvent(timeoutEvent);
			
			if(!this.hasEventListener(SocketChannelEvent.TIMEOUT))
				trace("Error:	未处理的超时错误：" + timeoutEvent.toString());
			
			if(!timeoutEvent.isDefaultPrevented())
				clear();
		}
		
		/**
		 *	传输块大小，以KB为单位，无限制大小；<b>如果数据块太大，可能会导致数据传输失败或超时</b>，默认为10KB/块。
		 * @throws   IllegalOperationError 数据正在传输过程中，不可操作此属性。
		 * @return 返回传输块设置的大小
		 */		
		public function get blockSize():uint{		return _blockSize/1024;	}
		public function set blockSize(value:uint):void
		{
			if(_blockIndex == -1)
				if(value > 0)
					_blockSize = value * 1024;
			else
				throw new IllegalOperationError("UDPSocketChannel::数据正在传输不可操作blockSize属性。");
		}
		
		/**	
		 * 数据块传输等待时间(s)超时，默认为3秒。 
		 * @throws   IllegalOperationError 数据正在传输过程中，不可操作此属性。
		 */		
		public function get timeout():uint{	return _timeout;	}
		public function set timeout(value:uint):void
		{
			if(_blockIndex != -1)
				throw new IllegalOperationError("UDPSocketChannel::数据正在传输不可操作timeout属性。");
			
			if(value > 0)
			{
				_timeout = value;
				_timer.repeatCount = _timeout;
			}
			else
			{
				throw new ArgumentError("UDPSocketChannel::timeout必须大于0.");
			}
		}
		
		/**
		 *	传输通道是否空闲 
		 * 	@return 空闲状态返回true,繁忙状态返回false
		 */
		public function get isIdle():Boolean{		return _blockIndex == -1;	}
		
	}
}