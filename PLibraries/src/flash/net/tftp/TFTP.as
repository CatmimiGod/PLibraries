package flash.net.tftp
{
	import flash.utils.ByteArray;

	/**
	 *	TFTP协议功能类，只是参考TFTP协议进行修改
	 * @author Administrator
	 */	
	public class TFTP
	{
		/**	读取请求操作码	0x0001	*/
		public static const OPCODE_RRQ:uint = 0x0001;
		/**	写入请求操作码	0x0002	*/
		public static const OPCODE_WRQ:uint = 0x0002;
		/**	数据块操作码		0x0003	*/
		public static const OPCODE_DATA:uint = 0x0003;
		/**	应答操作码	0x0004	*/
		public static const OPCODE_ACK:uint = 0x0004;
		/**	差错操作码	0x0005	*/
		public static const OPCODE_ERROR:uint = 0x0005;
		/**	OACK	0x0006	*/
		public static const OPCODE_OACK:uint = 0x0006;		
		/**	[增加]中断码Interrupt	0x0007	*/
		public static const OPCODE_INTERRUPT:uint = 0x0007;
		
		/**	8位源数据类型，二进制模式	octet	*/
		public static const MODE_OCTET:String = "octet";
		
		/**	8位的ASCII码形式，文本模式	netascii	*/
		public static const MODE_NETASCII:String = "netascii";
		
		/**	[增加]8位的ASCII码形式，文本模式	message 文字信息	*/
		public static const MODE_MESSAGE:String = "message";
		
		/**	 定界符	0x00	*/
		public static const DELIMITER:uint = 0x00;
		
		
		/**
		 * 创建一个读写请求包<br/>
		 * 读写请求格式 |	2B操作码	｜	文件名	｜0｜	模式	｜0｜	选项1	｜0｜	值1	｜0｜...｜	选项n	｜0｜	值n	｜0｜
		 * <br/>
		 * @param opcode:uint	读写操作码
		 * @param fileName:String	文件名
		 * @param mode:String		模式
		 * @param otherArgs:Object	其它参数
		 * 
		 * @throws ArgumentError 读写操作码错误或模式错误。
		 * @return 返回一个读写请求的字节包
		 */
		public static function createRequestPacket(opcode:uint, fileName:String, mode:String = "octet", otherArgs:Object = null):ByteArray
		{
			if(opcode != OPCODE_RRQ && opcode != OPCODE_WRQ)
				throw new ArgumentError("createRequestPacket() 操作码错误，请求包操作必须为 OPCODE_RRQ 或 OPCODE_WRQ.");
			
			var ba:ByteArray = new ByteArray();
			ba.writeShort(opcode);				//2字节操作码
			ba.writeUTFBytes(fileName);			//文件名
			ba.writeByte(DELIMITER);			//0
			ba.writeUTFBytes(mode);				//模式
			ba.writeByte(DELIMITER);			//0
			
			if(otherArgs)
			{
				for(var prop:String in otherArgs)
				{
					ba.writeUTFBytes(prop);		//选项
					ba.writeByte(DELIMITER);	//0
					
					ba.writeUTFBytes(otherArgs[prop].toString());		//值
					ba.writeByte(DELIMITER);							//0
				}
			}
			
			ba.position = 0;			
			return ba;
		}
		
		/**
		 * 分析读写请求头数据
		 * @param bytes
		 * @return  返回分析结果
		 */		
		public static function parseRequestPacket(bytes:ByteArray):Object
		{
			bytes.position = 2;
			
			var i:int = 2;
			var index:int = 0;
			var args:Vector.<String> = new Vector.<String>();			
			args[index] = "";
			
			while(i <= bytes.length - 1)
			{
				if(bytes[i] == 0x00)
				{
					index ++;
					args[index] = "";
				}
				else					
				{
					args[index] += String.fromCharCode(bytes.readUnsignedByte());
				}
				
				i ++;
				bytes.position = i;
			}
			
			var obj:Object = {name:args[0], mode:args[1]};
			var len:int = args.length;
			
			if(len > 2)
			{
				for(i = 2; i < len - 1; i += 2)
				{
					obj[args[i]] = args[i + 1];
				}
			}
			
			return obj;
		}
	
		/**
		 * 创建一个数据包。<br/>
		 * 数据包结构 ｜2B操作码｜2B块编号｜数据｜<br/>
		 * 
		 * @param data
		 * @param blockIndex
		 * @param blockSize
		 * 
		 * @return 回一个数据块字节包
		 */
		public static function createDataPacket(data:ByteArray, blockIndex:uint, blockSize:uint):ByteArray
		{
			var offset:uint = blockIndex * blockSize;
			
			if(offset >= data.length)
				return new ByteArray();
			
			var ba:ByteArray = new ByteArray();
			ba.writeShort(OPCODE_DATA);
			ba.writeShort(blockIndex);
			
			var length:uint = data.length - offset > blockSize ? blockSize : data.length - offset;
			ba.writeBytes(data, offset, length);
			ba.position = 0;
			
			return ba;
		}
		
		/**
		 *	创建一个应答包 
		 * @param blockIndex:uint	块索引
		 * @return 返回一个应答包字节数组
		 */		
		public static function createACKPacket(blockIndex:uint):ByteArray
		{
			var ba:ByteArray = new ByteArray();
			ba.writeShort(OPCODE_ACK);
			ba.writeShort(blockIndex);
			
			ba.position = 0;
			
			return ba;
		}
	
	
	}
}