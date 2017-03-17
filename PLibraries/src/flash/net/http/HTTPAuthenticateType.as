package flash.net.http
{
	/**
	 *	HTTP响应认证类型 
	 * @author Administrator
	 */	
	public final class HTTPAuthenticateType
	{
		/**
		 *	基本认证常量
		 * 	参考：http://zh.wikipedia.org/wiki/HTTP%E5%9F%BA%E6%9C%AC%E8%AE%A4%E8%AF%81
		 * 	
		 * 	@default "Basic"
		 */		
		public static const BASIC:String = "Basic";
		
		/**
		 *	摘要认证 常量
		 * 	参考：http://zh.wikipedia.org/wiki/HTTP%E6%91%98%E8%A6%81%E8%AE%A4%E8%AF%81
		 * 	
		 * @default "Digest"
		 */		
		public static const DIGEST:String = "Digest";
	}
}