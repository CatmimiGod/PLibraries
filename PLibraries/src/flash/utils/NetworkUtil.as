package flash.utils
{
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.URLVariables;

	/**
	 *	网络功能类 
	 * @author Administrator
	 * 
	 */	
	public class NetworkUtil
	{
		
		/**
		 *	获取本机有可用网络接口信息
		 * 	@return 返回URL变量
		 */		
		public static function getLocalAddressInfo():URLVariables
		{
			var macRegExp:RegExp = /([[:xdigit:]]{2}[-:]){5}[[:xdigit:]]{2}/i;
			
			var count:uint = 0;
			var source:String = "";
			var results:Vector.<NetworkInterface>  = NetworkInfo.networkInfo.findInterfaces();
				
			for (var i:int = 0; i< results.length; i++)
			{
				/**
				 * @internal
				 * 网络接口处于活动状态
				 * 网路适配器或接口卡的媒体访问控制 (MAC) 地址, 有可用的
				 * 网络接口的地址可用，且为IPv4类型
				 */
				if(results[i].active && macRegExp.test(results[i].hardwareAddress) && results[i].addresses.length > 0 && results[i].addresses[0].ipVersion == "IPv4")
				{
					var ips:String = "";
					var broadcasts:String = "";
					var len:uint = results[i].addresses.length;
					
					for (var j:int= 0; j < len; j++)
					{
						ips += results[i].addresses[j].address + (j == len - 1 ? "" : ",");
						broadcasts += results[i].addresses[j].broadcast + (j == len - 1 ? "" : ",");
					}
					
					source += StringFormat("mac_{0}={1}&ip_{0}={2}&broadcast_{0}={3}&", count, results[i].hardwareAddress, ips, broadcasts);
					count ++;
				}
			}
			
			source += "count=" + count;
			
			return new URLVariables(source);
		}
		
		/**
		 *	跟据网关或IP地址，获取局域网内同段IP地址 
		 * @param gateway
		 * @return 
		 */		
		public static function getLANAddress(gateway:String):String
		{
			var ipRegExp:RegExp = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/;
			if(!ipRegExp.test(gateway))
				throw new ArgumentError("getLANAddress参数错误，IP地址格式不正确。");
			
			var info:URLVariables = getLocalAddressInfo();	
			
			var source:String = "";
			var sele:String = gateway.substr(0, gateway.lastIndexOf("."));
			
			for(var i:int = 0; i < info.count; i ++)
			{
				var ip:Array = info["ip_" + i].split(",");
				for(var j:int = 0; j < ip.length; j ++)
				{
					if(ip[j].indexOf(sele) != -1)
						source += ip[j] + ",";
				}
			}
			
			return source.substr(0, source.length - 1);
		}
		
	}
}