package flash.air.process
{
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	/**
	 *	 启动程序或进程，无任何其它操作。
	 * <br /><br />
	 * 示例：var file:File = new File(File.applicationDirectory.nativePath + "/release/DemoApplicationService.exe");<br />
	 * startup(file);
	 * 
	 * @param file:File
	 * @param args:String	启动参数，可为空
	 * 
	 * @throws Error 此方法只适用于Win平台
	 * @throws ArgumentError 文件不存在
	 */		
	[inline]
	public function startup(file:File, args:String = "/min"):void
	{
		if(Capabilities.os.toLowerCase().indexOf("win") == -1)
			throw new Error("startup方法只适用于Win平台.");
		
		if(!file.exists)
			throw new ArgumentError("startup Error::文件不存在：" + file.nativePath);
		
		var path:String = file.nativePath;
		var bytes:ByteArray = new ByteArray();
		
		var drive:String = path.substr(0, 2);								//盘符
		var filePath:String = path.substring(0, path.lastIndexOf("\\"));	//路径
		var fileName:String = path.substr(path.lastIndexOf("\\") + 1);		//文件
		
		bytes.writeMultiByte(drive + "\n", "gb2312");
		bytes.writeMultiByte("cd \"" + filePath + "\"\n", "gb2312");
		//start args "title" "fileName"
		if(args == null)
			bytes.writeMultiByte("start  \"\" \"" + fileName + "\"\n", "gb2312");
		else
			bytes.writeMultiByte("start " + args + " \"\" \"" + fileName + "\"\n", "gb2312");
		
		bytes.writeMultiByte("exit\n", "gb2312");
		
		var localProcess:LocalProcess = new LocalProcess(new File("C:/Windows/System32/cmd.exe"));
		localProcess.standardInput.writeBytes(bytes, 0, bytes.length);
	}	

}