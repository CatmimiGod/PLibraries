package flash.customprotocol
{
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.sendToURL;
	import flash.utils.Base64;
	import flash.utils.ByteArray;

	/**
	 *	华为松山湖项目，网络开关 
	 * @author Administrator
	 * 
	 * 16路串口继电器 电脑控制开关 电脑灯光控制 电磁阀控制 232/485
	 * https://item.taobao.com/item.htm?id=16108249070&spm=2014.21600712.0.0
	 * 
	 * 备份原来的程序，将原来程序包中的PPT文件复制到新的程序包中即可运行
	 */	
	public final class NetworkSwitcher_B
	{
		/**	继电器控制命令 位开	*/		
		public static const CMD_ON:uint = 0x01;
		/**	继电器控制命令 位关	*/
		public static const CMD_OFF:uint = 0x02;
		/**	继电器控制命令 全开	*/
		public static const CMD_ALL_ON:uint = 0x03;
		/**	继电器控制命令 全关	*/
		public static const CMD_ALL_OFF:uint = 0x04;
		/**	继电器控制命令 组开	*/
		public static const CMD_GROUP_ON:uint = 0x05;
		/**	继电器控制命令 组关	*/
		public static const CMD_GROUP_OFF:uint = 0x06;
		/**	继电器控制命令 读状态	*/
		public static const CMD_STATUS:uint = 0x07;
		/**	继电器控制命令 读地址	*/
		public static const CMD_READ_ADDRESS:uint = 0x10;
		/**	继电器控制命令 设置地址	*/
		public static const CMD_WRITE_ADDRESS:uint = 0x11;
		
		
		/**
		 *	获取控制16路继电器控制命令字节 
		 * @param cmd
		 * @param args
		 * @return 
		 */		
		public static function getByteArray(cmd:uint, args:uint = 0x000000):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUnsignedInt(0x005A6000);
			
			switch(cmd)
			{
				case CMD_ON:
				case CMD_OFF:
					bytes.writeByte(cmd);
					
					if(args > 0xFF)
						throw new ArgumentError("参数错误，值应该小于0xFF");
					
					bytes.writeByte(args);
					bytes.writeShort(0x0000);
					break;
				
				case CMD_STATUS:
				case CMD_ALL_ON:
				case CMD_ALL_OFF:				
					bytes.writeByte(cmd);
					bytes.writeByte(0x00);
					bytes.writeByte(0x00);
					bytes.writeByte(0x00);
					break;
				
				case CMD_GROUP_ON:
				case CMD_GROUP_OFF:
					bytes.writeByte(cmd);
					
					if(args > 0xFFFF)
						throw new ArgumentError("参数错误，值应该小于0xFFFF");
					
					bytes.writeByte(0x00);
					break;
				
				case CMD_READ_ADDRESS:
				case CMD_WRITE_ADDRESS:
					bytes.writeByte(cmd);
					
					if(args > 0xFE)
						throw new ArgumentError("参数错误，值应该小于0xFE");
					
					bytes.writeByte(args);
					bytes.writeShort(0x0000);
					break;
				
				default:
					throw new ArgumentError("参数错误，不存在的命令 " + cmd);
			}
			
			//校验和
			var mod:uint = 0x00;
			var len:uint = bytes.length;
			for(var i:uint = 0; i < len; i ++)
			{
				mod += bytes[i];
			}
			
			bytes.writeByte(mod);
			bytes.position = 0;
			
			return bytes;
		}
		
		/** 投影机网络控制开命令	*/
		public static const PRO_CM_ON:String = "0200a13d0103";
		/** 投影机网络控制关命令	*/
		public static const PRO_CM_OFF:String = "0200a13d0203";
		
		/**
		 * 发送投影机控制命令
		 * @param ip
		 * @param cmd
		 * @param user
		 * @param password
		 */			
		public static function sendProjectorCommand(ip:String, cm:String, user:String = null, password:String = null):void
		{
			var url:String;
			switch(cm)
			{
				case PRO_CM_ON:
				case PRO_CM_OFF:
					url = "http://" + ip + "/cgi-bin/sd95cgi?cm=" + cm;
					break;
					
				default:
					throw new ArgumentError("参数错误，不存在的命令 " + cm);
			}
			
			var request:URLRequest = new URLRequest(url);
			request.requestHeaders = [new URLRequestHeader("Connection", "Close")];
			
			trace(url);
			//需要认证，基本认证
			if(user != null && password != null && user.length > 0 && password.length > 0)
			{
				var basicAuthor:String = Base64.encode(user + ":" + password);	trace(basicAuthor);
				request.requestHeaders.push(new URLRequestHeader("Authorizatio", "Basic " + basicAuthor));
			}
			
			sendToURL(request);
		}
		
		
		public static function sendPCCommand(ip:String, cmd:String = "shutdown -s -t 00"):void
		{
			var url:String = "http://" + ip + ":2000/index.html?funcName=runCmd&args=" + cmd;
			
			var request:URLRequest = new URLRequest(url);
			request.requestHeaders = [new URLRequestHeader("Connection", "Close")];
			
			sendToURL(request);
		}
		
	}
}