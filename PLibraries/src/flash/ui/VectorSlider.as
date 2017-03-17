package flash.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.graphics.Circle;
	import flash.graphics.RoundRectangle;
	
	[Event(name="Event.CHANGE", type="flash.events.Event")]
	
	/**
	 *	定制的矢量进度拉条 
	 * @author Huangmin
	 */	
	public class VectorSlider extends VectorProgress
	{
		/**	拖动的按扭	*/
		public var thumbBtn:Sprite;
		private var _thumbBtn:Circle;
		
		/**	点击定位的定位条，可选对象	*/
		public var positionBar:Sprite;
		private var _positionBar:RoundRectangle;
		
		private var _radius:Number;
		
		/**
		 *	Constructor. 
		 */		
		public function VectorSlider()
		{
			super();
			
			if(positionBar == null && thumbBtn == null)
			{
				//PositionBar
				_positionBar = new RoundRectangle();
				_positionBar.setSize(backgroundBar.width, backgroundBar.height);
				_positionBar.alpha = 0;
				
				positionBar = new Sprite();
				positionBar.addChild(_positionBar);
				this.addChild(positionBar);
				
				//ThumbButtom
				_thumbBtn = new Circle();
				_thumbBtn.setSize(backgroundBar.height * 2, backgroundBar.height * 2);
				_thumbBtn.thickness = 3;
				_thumbBtn.color = _backgroundColor;
				_thumbBtn.lineColor = _progressColor;
				_thumbBtn.x = - _thumbBtn.width * .5;
				_thumbBtn.y = - _thumbBtn.height * .25;
				
				thumbBtn = new Sprite();
				thumbBtn.buttonMode = true;
				thumbBtn.addChild(_thumbBtn);
				this.addChild(thumbBtn);
			}
			
			positionBar.addEventListener(MouseEvent.CLICK, onPositionClickHandler);
			thumbBtn.addEventListener(MouseEvent.MOUSE_DOWN, onThumbMouseDownHandler);
			
			this.value = 0;
		}
		
		/**
		 * @private
		 *	点击定位 
		 */	
		private function onPositionClickHandler(e:MouseEvent):void
		{
			var px:Number = positionBar.mouseX / positionBar.width;
			this.value = px * maxValue;
		}
		
		private var _isDown:Boolean = false;
		private function onThumbMouseDownHandler(e:MouseEvent):void
		{
			_isDown = true;
			this.addEventListener(Event.ENTER_FRAME, onEnterFrameEventHandler, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpEventHandler, false, 0, true);
		}
		
		private function onEnterFrameEventHandler(e:Event):void
		{
			var mx:Number = this.mouseX <= 0 ? 0 : this.mouseX >= _positionBar.width ? _positionBar.width : this.mouseX;
			//trace(mx);
			if(_isDown)
			{
				var px:Number = mx / _positionBar.width;
				this.value = px * maxValue;
			}
		}
		
		/**
		 *	@private 
		 * 	鼠标事件，点击释放舞台
		 */		
		private function onMouseUpEventHandler(e:MouseEvent):void
		{
			_isDown = false;
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrameEventHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpEventHandler);
		}
		
		override public function set value(v:Number):void
		{
			super.value = v;
			if(thumbBtn)
				thumbBtn.x = v / maxValue * _positionBar.width;
		}
		
		override public function set width(value:Number):void
		{
			if(_positionBar != null)
				_positionBar.width = value;
			
			super.width = value;
		}
		override public function set height(value:Number):void
		{
			_thumbBtn.x = - _thumbBtn.width * .5;
			_thumbBtn.y = - _thumbBtn.height * .25;
		}
		
	}
}