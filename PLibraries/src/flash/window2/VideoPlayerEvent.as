package flash.window2
{
	import flash.events.Event;
	
	/**
	 *	 VideoPlayerController Event
	 * @author Administrator
	 */	
	public class VideoPlayerEvent extends Event
	{
		/**视频播放状态改变时事件常量*/		
		public static const CHANGE:String = "video_state_change";
		
		private var _stateCode:uint;
		
		public static const STATE_CODE_UNDEFINED:uint = 0;
		public static const STATE_CODE_STOPPED:uint = 1;
		public static const STATE_CODE_PAUSED:uint = 2;
		public static const STATE_CODE_PLAYING:uint = 3;
		public static const STATE_CODE_SCANFORWARD:uint = 4;
		public static const STATE_CODE_SCANFEVERSE:uint = 5;
		public static const STATE_CODE_BUFFERING:uint = 6;
		public static const STATE_CODE_WATING:uint = 7;
		public static const STATE_CODE_MEDIA_ENDED:uint = 8;
		public static const STATE_CODE_TRANSITIONING:uint = 9;
		public static const STATE_CODE_READY:uint = 10;
		public static const STATE_CODE_RECONNECTION:uint = 11;
		public static const STATE_CODE_LAST:uint = 12;
		
		/**
		 * 
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function VideoPlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, stateCode:uint = 0)
		{
			this._stateCode = stateCode;
			super(type, bubbles, cancelable);
		}
		
		/**
		 *	视频播放状态码 
		 */	
		public function get stateCode():uint
		{
			return this._stateCode;
		}
		
		/**
		 *	@inheritDoc. 
		 */		
		override public function clone():Event
		{
			return new VideoPlayerEvent(type, bubbles, cancelable);
		}
		
		/**
		 *	@inheritDoc. 
		 */	
		override public function toString():String
		{
			return super.formatToString(type, bubbles, cancelable);
		}
	}
}