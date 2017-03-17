package flash.air.process
{
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;

	/**
	 *	结束进程
	 * <br /><br />
	 * 示例： taskkill("DemoApplicationService.exe");
	 * 
	 * @param processName:String	进程名 
	 * 
	 * @throws Error 此方法只适用于Win平台
	 */	
	[inline]
	public function taskkill(processName:String):void
	{
		if(Capabilities.os.toLowerCase().indexOf("win") == -1)
			throw new Error("taskkill方法只适用于Win平台.");
		
		if(processName.indexOf("\\") != -1)
			processName = processName.substr(processName.lastIndexOf("\\") + 1)
		
		var bytes:ByteArray = new ByteArray();
		bytes.writeMultiByte("taskkill /f /im \"" + processName + "\"\n", "gb2312");
		bytes.writeMultiByte("exit\n", "gb2312");
		
		var localProcess:LocalProcess = new LocalProcess(new File("C:/Windows/System32/cmd.exe"));
		localProcess.standardInput.writeBytes(bytes, 0, bytes.length);
	}
}