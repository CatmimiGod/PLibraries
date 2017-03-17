package flash.net.http
{
	/**
	 *	创建一个封装单个 HTTP 响应标头的新 HTTPResponseHeader 对象。 
	 * @author Administrator
	 */	
	public final class HTTPResponseHeader
	{
		/**
		 *	HTTP 响应标头名称 
		 */		
		public var name:String;
		
		/**
		 *	与 name 属性相关联的值 
		 */		
		public var value:String;
		
		/**
		 * 新 HTTPResponseHeader 对象
		 * @param name
		 * @param value
		 */		
		public function HTTPResponseHeader(name:String = "", value:String = "")
		{
			this.name = name;
			this.value = value;
		}
		
		public function toString():String
		{
			return name + ": " + value + "\r\n";
		}
	}
}