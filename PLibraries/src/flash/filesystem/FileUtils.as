package flash.filesystem
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.text.StyleSheet;
	import flash.utils.ByteArray;
	import flash.xml.XMLDocument;
	
	/**
	 * 	FileUtils
	 * 
	 * 	所有同步数据存取,都只适合较小的文件.
	 * 
	 * <p>最后更新时间：2012-12-06 huang</p>
	 * 
	 * @playerversion AIR 1.0
	 */ 
	public class FileUtils
	{
		/**	数据类型为XML */ 
		public static const XML:String = "xml";
		
		/**	数据类型为txt文本 */ 
		public static const TXT:String = "txt";
		
		/**	数据类型为css文本	 */
		public static const CSS:String = "css";
		
		/**
		 *	异步写入文本数据至文件,新建文件或已经存在的文件。
		 * 
		 * @param file:File 需要写入的文件
		 * @param data:String 写入的内容，为String类型
		 * @param fileMode:String 写入方式
		 * @param fileType:String 文件类型，为文本型
		 * 
		 * @playerversion AIR 1.0
		 */
		public static function asyncWriteString(file:File, data:String, fileMode:String = FileMode.WRITE, fileType:String = FileUtils.XML):void
		{
			var fileStream:FileStream = new FileStream();
			fileStream.openAsync(file, FileMode.WRITE);				
			fileStream.addEventListener(Event.COMPLETE, onUpdateConfigDataComplete);
			
			switch(fileType)
			{
				case FileUtils.XML:
					var xmlHead:String = '<?xml version="1.0" encoding="utf-8"?>\n\n';
					fileStream.writeUTFBytes(String(xmlHead + data));
					break;
				
				case FileUtils.TXT:
				case FileUtils.CSS:
					fileStream.writeUTFBytes(data);
					break;
				
				default:
					throw new ArgumentError("fileType参数错误！！");
			}
		}
		protected static function onUpdateConfigDataComplete(e:Event):void
		{
			trace("异步写入数据完成！");
			
			var fileStream:FileStream = FileStream(e.target);			
			fileStream.close();
			fileStream.removeEventListener(Event.COMPLETE, onUpdateConfigDataComplete);
		}
		
		/**
		 * 	以同步的方式读取String文件类型,并返回数据.
		 * 	@param file:File
		 * 	@return 字符;
		 * 
		 * 	@throws ArgumentError 指定的文件不存在.
		 * 	@playerversion AIR 1.0
		 */
		public static function readStringFile(file:File):String
		{
			var content:String;
			if(file.exists)
			{
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				
				content = fileStream.readUTFBytes(fileStream.bytesAvailable);
				fileStream.close();
			}
			else
			{
				throw new ArgumentError("FileUtils.readStringFile()指定的文件不存在：" + file.nativePath);
			}
			
			return content;
		}
		
		/**
		 *	 以同步的方式写入ByteArray到本地电脑 , file路径问题,var file:File = new File(File.applicationDirectory.nativePath + "//aa.jpg");
		 * 	@param ba:ByteArray
		 * 	@param file:File
		 */
		public static function writeByteArrayFile(ba:ByteArray, file:File):Boolean
		{
			var success:Boolean = false;
			
			var fs:FileStream = new FileStream();
			
			try
			{
				fs.open(file, FileMode.WRITE);
				fs.writeBytes(ba, 0, ba.bytesAvailable);
				success = true;
			}
			catch(e:Error)
			{
				success = false;
			}
			fs.close();
			
			return success;
		}
		
	}
}

