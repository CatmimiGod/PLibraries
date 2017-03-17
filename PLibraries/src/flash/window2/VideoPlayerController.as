package flash.window2
{
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.utils.Base64;
	
	/**
	 *	视频播放状态改变后调用 
	 * @author Administrator
	 */	
	[Event(name=VideoPlayerEvent.CHANGE, type="flash.events.VideoPlayerEvent")]
	
	/**
	 *	C#窗体中WindowsMediaPlayer容器对象；此对象不可实例化，需通过Application.getVideoPlayerInstance()获取实例；
	 * @author Administrator
	 */	
	public final class VideoPlayerController extends EventDispatcher
	{
		private var _url:String;
		private var _volume:uint;
		
		private var _mute:Boolean;
		private var _autoLoop:Boolean;
		private var _autoStart:Boolean;
		
		private var _playing:Boolean;
		private var _playState:uint = 0;
		private var _playCount:uint = 0;
		
		private var _duration:Number;
		private var _durationString:String;
		private var _position:Number;
		private var _positionString:String;
		
		private var _visible:Boolean;
		private var _childIndex:uint = 0;
		private var _size:Rectangle = new Rectangle();
		
		private var _focused:Boolean;
	
		/**
		 * 窗体视频控制对象
		 *	Constructor 
		 */		
		public function VideoPlayerController(pic:PrivateInternalClass)
		{
			//优先提供回调函数
			ExternalInterface.addCallback("callBackPlayingChange", callBackPlayingChange);
			ExternalInterface.addCallback("callBackVideoPlayerInfo", callBackVideoPlayerInfo);
			
			//this._visible = true;			
			ExternalInterface.call("videoEnabled", true);
		}
				
		/**
		 * @private
		 *	C#回调，时实返回更新视频信息参数 
		 */		
		private function callBackVideoPlayerInfo(...args):void
		{
			if(args.length != 17)
				return;
			
			this._size.x = int(args[0]);
			this._size.y = int(args[1]);
			this._size.width = int(args[2]);
			this._size.height = int(args[3]);
			this._visible = args[4].toLowerCase() == "true";
			
			this._url = args[5];
			this._playState = uint(args[6]);
			this._playing = uint(args[6]) == 3;
			
			this._mute = args[7].toLowerCase() == "true";
			this._volume = Number(args[8]);
			
			this._autoStart = args[9].toLowerCase() == "true";
			this._playCount = uint(args[10]);
			
			this._position = Number(args[11]);
			this._positionString = args[12];
			
			this._duration = Number(args[13]);
			this._durationString = args[14];
			
			this._autoLoop = args[15].toLowerCase() == "true";		
			this._focused = args[16].toLowerCase() == "true"
			//WindowsFormsApplication.getDebugInstance().consoleTrace(args.toString());
		}
		/**
		 * @private
		 *	C#回调，返回视频播放状态事件 
		 */		
		private function callBackPlayingChange(...args):void
		{
			if(args.length > 0)
				this.dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.CHANGE, false, false, uint(args[0])));
		}
		
		
		/**	播放视频	*/
		public function play():void
		{	
			ExternalInterface.call("videoPlay");	
		}
		
		/**	暂停视频	*/
		public function pause():void
		{	
			ExternalInterface.call("videoPause");	
		}
		
		/**	
		 * 停止视频<br />
		 * 当<code>autoLoop</code>为true时，调用stop()视频将会自动从头开始播放；autoLoop为false时，调用stop()视频则会停止；<br>
		 * 所以建议调用pause()方法；
		 * @see pause	
		 */
		public function stop():void
		{	
			ExternalInterface.call("videoStop");	
		}
		
		/**
		 *	设置视频控件焦点，以接收键盘事件 
		 */		
		public function focus():void
		{
			ExternalInterface.call("videoFocus");	
		}
		
		/**	获取控件是否具有输入焦点	*/
		public function get focused():Boolean{	return _focused;	}
		/**
		 *	视频播放位置 
		 * @return 
		 */		
		public function get position():Number{	return this._position;	}
		public function set position(value:Number):void
		{
			if(value >= 0 && value <= this._duration)
			{
				this._position = value;
				ExternalInterface.call("videoPosition", _position);
			}
		}
		
		/**	视频URL位置 */		
		public function get url():String{	return _url;	}
		public function set url(value:String):void
		{
			if(value == null)	return;
			
			this._url = value;
			ExternalInterface.call("videoURL", this._url);
		}
		
		/**
		 *	视频音量设置 
		 * @return 返回音量值0-100
		 */		
		public function get volume():uint{	return this._volume;	}
		public function set volume(value:uint):void
		{
			_volume = value > 100 ? 100 : value;
			ExternalInterface.call("videoVolume", _volume);
		}
		
		/**	视频是否是静音状态 */		
		public function get mute():Boolean{	return this._mute;	}
		public function set mute(value:Boolean):void
		{
			this._mute = value;
			ExternalInterface.call("videoMute", this._mute.toString());
		}
		
		/**	是否自动播放视频*/		
		public function get autoStart():Boolean{	return this._autoStart;	}
		public function set autoStart(value:Boolean):void
		{
			this._autoStart = value;
			ExternalInterface.call("videoAutoStart", this._autoStart.toString());
		}
		
		/**	视频是否自动循环播放 */		
		public function get autoLoop():Boolean{	return _autoLoop;	}
		public function set autoLoop(value:Boolean):void
		{
			_autoLoop = value;
			ExternalInterface.call("videoAutoLoop", this._visible.toString());
		}
		
		/**	获取或设置调试窗口的可见性*/		
		public function get visible():Boolean{	return this._visible;	}
		public function set visible(value:Boolean):void
		{
			this._visible = value;
			ExternalInterface.call("videoVisible", value.toString());
		}
		
		/**	获取或设置调试窗口的位置及大小*/	
		public function get size():Rectangle{		return this._size;	}
		public function set size(value:Rectangle):void
		{
			if(value == null)	return;
			
			this._size = value;
			var params:String = Math.round(value.x) + "," + Math.round(value.y) + "," + Math.round(value.width) + "," + Math.round(value.height);
			ExternalInterface.call("videoSize", params);
		}
		
		/**返回视频的播放状态*/
		public function get playState():uint{		return this._playState;	}
		
		/**	返回视频是否正在播放	*/
		public function get playing():Boolean{	return this._playing;	}
		
		/**	返回视频持续时间	*/
		public function get duration():Number{	return this._duration;	}
		
		/**	返回视频播放头位置，以"00:42"形式返回字符	*/
		public function get positionString():String{	return this._positionString;	}
		
		/**	返回视频持续时间，以"00:42"形式返回字符	*/
		public function get durationString():String{	return this._durationString;	}
		
	}
}
