package flash.model
{
	public class SubmitDataStatus
	{
		/**
		 * success
		 */
		public static const SUCCESS:uint = 0x01;
		
		/**
		 * repert
		 */
		public static const REPEAT:uint = 0x10;
		
		/**
		 * not regist
		 */
		public static const NOT_REGIST:uint = 0x11;
		
		/**
		 * ....
		 */
		public static const IO_ERROR:uint = 0x20;
		
		/**
		 * ......
		 */
		public static const SECURITY_ERROR:uint = 0x21;
		
		/**
		 * return all status
		 * @return
		 */
		/*internal function getStatus():Vector.<uint>
		{
		return new <uint>[SUCCESS, REPEAT, NOT_REGIST, IO_ERROR, SECURITY_ERROR];
		}
		*/
	}
}