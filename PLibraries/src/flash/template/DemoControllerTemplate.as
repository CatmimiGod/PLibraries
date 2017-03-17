package flash.template
{
	import flash.controller.NetworkController;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SOCookie;
	
	/**
	 *	Demo Controller Template	移动端网络控制通用模板 
	 * @author Administrator
	 */	
	public class DemoControllerTemplate extends Sprite
	{
		/**	本地存储	*/
		protected var localCookieName:String;
		/**网络控制配置对象*/
		protected var networkConfig:Object;
		/**	网络控制器	*/
		protected var networkController:NetworkController;
		
		/**
		 *	Constructor. 
		 */	
		public function DemoControllerTemplate(cookieName:String = null)
		{
			if(cookieName == null)
				throw new ArgumentError("DemoControllerTemplate::本地Cookie名称不能为空");
			
			//SOCookie.clearCookie(cookieName);
			this.localCookieName = cookieName;
			var size:uint = SOCookie.getCookieSize(cookieName);
			
			if(size > 0)
				networkConfig = SOCookie.getCookie(localCookieName);
			
			if(this.hasOwnProperty("btn_setWin") && this.hasOwnProperty("mc_setWin"))
			{
				this["mc_setWin"].setInteractive(size <= 0);
				this.setChildIndex(this["mc_setWin"], this.numChildren - 1);
				
				this["btn_setWin"].addEventListener(MouseEvent.CLICK, onClickHandler);
			}
			else
			{
				trace("DemoControllerTemplate::没找到mc_setWin、btn_setWin显示对象。");
			}
			
			initialize();
		}
		
		/**
		 *	initialize. <br />
		 * 	setting stage property and native applicate some properties
		 */		
		protected function initialize():void
		{
			/**
			 * @internal
			 * 避免左右或上下留空边，移动端添加缩放,因为华为PAD都有虚拟按键条
			 */
			stage.align = StageAlign.TOP_LEFT;
			//stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			/**
			 * @internal
			 * 如果需要退出后断开连接添加以下代码
			 */
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onNativeApplicationEventHandler);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onNativeApplicationEventHandler);
		}
		
		private function onClickHandler(e:MouseEvent):void
		{
			if(this.hasOwnProperty("mc_setWin"))
				this["mc_setWin"].setInteractive(true);
		}
		
		/**
		 *	设置语言 
		 * @param lang
		 */		
		public function setLanguage(lang:String = null):void
		{
		}
		
		/**
		 *	重新连接服务 
		 */		
		public function connectNetwork(config:Object):void
		{
			closeNewtork();
			networkConfig = config;
			
			if(networkController == null)
			{
				if(networkConfig != null)
					networkController = new NetworkController(this, networkConfig);
				else
					trace("Warning:::未设置networkConfig参数");
			}
		}
		
		/**
		 *	断开网络连接 
		 */		
		public function closeNewtork():void
		{
			if(networkController)
			{
				networkController.dispose();
				networkController = null;
			}
		}
		
		/**
		 * 	NativeApplication events handler
		 * 	@param e
		 */
		protected function onNativeApplicationEventHandler(e:Event):void
		{
			switch(e.type)
			{
				case Event.ACTIVATE:
					//还原窗体时，重新连接服务器
					connectNetwork(networkConfig);
					break;
				
				case Event.DEACTIVATE:
					//最小化时，断开连接
					closeNewtork();
					break;
			}
		}
		
		/** 获取cookie名称*/		
		public function get cookieName():String	{	return this.localCookieName;	}
		
	}
}