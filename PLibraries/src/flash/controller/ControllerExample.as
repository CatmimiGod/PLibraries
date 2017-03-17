package flash.controller
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	
	/**
	 *	此类为键盘控制器与网络控制器代码应用示例 
	 * <a href="https://192.168.15.170/svn/2015/trunk/PLibraries/src/flash/controller/ControllerExample.as" target="_blank">查看源码</a>
	 * @author Huangm
	 * 
	 */	
	public class ControllerExample extends Sprite
	{
		private var mc:MovieClip;
		
		/**
		 *	Contructor. 
		 */		
		public function ControllerExample()
		{
			super();
		}
		
		private function initialize():void
		{
			//关于mc此些省略…………
			
			//客户端网络控制器设置
			//参数config可为XML
			var config:XML = <data>
								<network>
									<port>2000</port>
									<address>127.0.0.1</address>
									<demoName>DN</demoName>
								</network>
							</data>
			var networkController:NetworkController = new NetworkController(this, config.network);
			//或
			//var networkController:NetworkController = new NetworkController(this, {demoName:"DN", port:2000, address:"127.0.0.1"});
			
			//键盘控制
			var keyboardController:KeyboardController = new KeyboardController(this);
			keyboardController.addKeyUpFunc(Keyboard.ENTER, mc.play);
			keyboardController.addKeyDownFunc(Keyboard.A, mc.gotoAndPlay, 2);
			keyboardController.addKeyDownFunc(Keyboard.B, testArgs, "hello", 250);
			keyboardController.addKeyDownFunc(Keyboard.C, "testArgs", "hello", 250);
			
			keyboardController.removeKeyDownFunc(Keyboard.B);
		}
		
		public function testArgs(arg0:String, arg1:Number):void
		{
			trace(arg0 + ">>" + arg1);
		}
			
	}
}