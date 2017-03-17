package flash.customprotocol
{
	import flash.utils.ByteArray;

	/**
	 *	唐山网络开关功能类 
	 * @author huangm
	 * 
	 * 工业级全物理隔离16路串口/网口继电器板 继电器控制板 网络继电器 远程控制 可编程控制
	 * https://item.taobao.com/item.htm?spm=a230r.1.14.198.ZcAhJ4&id=24846560779&ns=1&_u=m4399he111c&abbucket=15#detail
	 */	
	public class NetworkSwitcher_A
	{
		/**	状态查询	*/
		public static const REQUEST:uint = 0x10;
		
		/**	断开指令	*/
		public static const OFF:uint = 0x11;
		
		/**	吸合指令，也就是开	*/
		public static const ON:uint = 0x12;
		
		/**	翻转	*/
		//public static const OFFON:uint = 0x09;
		
		/**	读取状态指令	*/
		public static const READSTATUS:uint = 0x10;	
		
		/**
		 * 按位执行
		 * 数据中的第3，4个字节，每个字节8位，共16位。
		 * 代表16路继电器的状态，1代表吸合0代表断开。
		 * 最后一个字节的第0位代表第一个继电器，依次类推
		 */
		public static const BIT:uint = 0x13;
		
		/**
		 * 数据中的第3，4个字节，每个字节8位，共16位。
		 * 代表16个继电器的操作，1代表断开0代表保持原来状态。
		 * 最后一个字节的第0位代表第一个继电器，依次类推。
		 */		
		public static const OFFGROUP:uint = 0x14;
		
		/**
		 *	数据中的第3，4个字节，每个字节8位，共16位。 
		 */		
		public static const ONGROUP:uint = 0x15;
		
		protected static function getSendByteArray(addr:uint, cmd:uint, bytesData:Vector.<uint>):ByteArray
		{
			if(bytesData.length != 4)
				throw new Error("bytesData::长度必须为4.");
			
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeByte(0x55);
			byteArray.writeByte(addr);
			byteArray.writeByte(cmd);
			
			for(var i:int = 0; i < 4; i ++)
			{
				byteArray.writeByte(bytesData[i]);
			}
			
			var mod:uint = 0x00;
			byteArray.position = 0;
			for(i = 0; i < 7; i ++)
			{
				mod += byteArray.readByte();
			}
			
			byteArray.writeByte(mod);
			byteArray.position = 0;
			
			return byteArray;
		}
		
		public static function requestStatus():ByteArray
		{
			return getSendByteArray(0x01, REQUEST, new <uint>[0x00, 0x00, 0x00, 0x00]);
		}
		
		/**
		 *	获取单一命令 
		 * @param index
		 * @param cmd
		 * @return 
		 */		
		public static function setSingleCommand(index:uint, cmd:uint):ByteArray
		{
			return getSendByteArray(0x01, cmd, new <uint>[0x00, 0x00, 0x00, index]);
		}
		
		/**
		 *	关闭所有开关 
		 * @return 
		 */		
		public static function closeAll():ByteArray
		{
			return getSendByteArray(0x01, BIT, new <uint>[0x00, 0x00, 0x00, 0x00]);
		}
		
		/**
		 *	打开所有开关 
		 * @return 
		 */	
		public static function openAll():ByteArray
		{
			return getSendByteArray(0x01, BIT, new <uint>[0x00, 0x00, 0xFF, 0xFF]);
		}
	}
}

