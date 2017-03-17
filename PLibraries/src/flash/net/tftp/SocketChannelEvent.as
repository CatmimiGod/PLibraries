package flash.net.tftp
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	/**
	 *	TFTP数据传输事件 
	 * @author Huangmin
	 */	
	public class SocketChannelEvent extends Event
	{
		/**	数据发送/接收请求事件常量	*/
		public static const REQUEST:String = "data_request"
		
		/**	数据发送/接收超时事件常量	*/
		public static const TIMEOUT:String = "tftp_timeout";
		
		/**	数据发送完成事件常量	*/
		public static const SEND_COMPLETE:String = "send_complete";
		
		/**	数据接收完成事件常量	*/
		public static const RECEIVE_COMPLETE:String = "receive_complete";
		
		/**	块索引	*/
		public var blockIndex:int = -1;
		/**	数据	*/
		public var data:ByteArray = null;
		/**	错误码	*/
		public var errorCode:int = -1;
		/**	操作码	*/
		public var opcode:uint = 0;
		/**发送/接收所持续的时间，以ms为单位*/
		public var duration:uint = 0;
		
		/**
		 * 
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * @param opcode
		 * @param blockIndex
		 * @param data
		 * @param errorCode
		 * @param duration
		 */				
		public function SocketChannelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, opcode:uint = 0, blockIndex:int = -1, data:ByteArray = null, errorCode:int = -1, duration:Number = 0)
		{
			super(type, bubbles, cancelable);
			
			this.data = data;
			this.opcode = opcode;
			this.errorCode = errorCode;
			this.blockIndex = blockIndex;
			this.duration = duration;
		}
		
		/**	@inheritDoc.	*/
		override public function clone():Event
		{
			return new SocketChannelEvent(type, bubbles, cancelable);
		}
		
		/**	@inheritDoc.	*/
		override public function toString():String
		{
			return super.formatToString("SocketChannelEvent", "type", "bubbles", "cancelable", "opcode", "blockIndex", "errorCode", "duration");
		}
	}
}