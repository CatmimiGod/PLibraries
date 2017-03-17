package flash.template
{
	/**
	 *	语言 
	 * @author Administrator
	 */	
	public class Language
	{
		
		public static const CN:String = "cn";
		
		public static const EN:String = "en";
		
		[inline]
		public static function check(lang:String):Boolean
		{
			var boo:Boolean = false;
			
			switch(lang)
			{
				case CN:
				case EN:
					boo = true;
					break;
			}
			
			return boo;
		}
		
	}
}