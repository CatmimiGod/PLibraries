package flash.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.graphics.RoundRectangle;
	
	/**
	 *	Change事件 
	 * 	@author Huangmin
	 */	
	[Event(name="Event.CHANGE", type="flash.events.Event")]
	
	/**
	 *	进度条 
	 * @author Administrator
	 * 
	 */	
	public class VectorProgress extends Sprite
	{
		/**	进度显示背景条	*/
		public var backgroundBar:Sprite;
		private var _backgroundBar:RoundRectangle;
		
		/**	进度显示条	*/
		public var progressBar:Sprite;
		private var _progressBar:RoundRectangle;
		
		private var _width:Number = 300;
		private var _height:Number = 15;
		
		private var _ellipse:Number = 14;
		protected var _progressColor:uint = 0x0066FF;
		protected var _backgroundColor:uint = 0x666666;
		
		private var _value:Number = 0;
		private var _percent:Number = 0;
		
		/**	进度最大值	*/
		public var maxValue:Number = 200;
		
		/**
		 *	Constructor. 
		 */		
		public function VectorProgress()
		{
			if(backgroundBar == null || progressBar == null)
			{
				//BackgroundBar
				_backgroundBar = new RoundRectangle();
				_backgroundBar.setSize(_width, _height);
				_backgroundBar.ellipse = this._ellipse;
				_backgroundBar.color = this._backgroundColor;
				
				backgroundBar = new Sprite();
				backgroundBar.addChild(_backgroundBar);
				this.addChild(backgroundBar);
				
				//PorgressBar
				_progressBar = new RoundRectangle();
				_progressBar.setSize(_width, _height);
				_progressBar.ellipse = this._ellipse;
				_progressBar.color = this._progressColor;
				
				progressBar = new Sprite();
				progressBar.addChild(_progressBar);
				this.addChild(progressBar);
			}
			else
			{
				_width = backgroundBar.width;
				_height = backgroundBar.height;
			}
			
			this.value = _value;
		}
		
		/**
		 *	进度值 
		 * @param v
		 */		
		public function get value():Number{	return _value;	}
		public function set value(v:Number):void
		{
			if(v < 0 || v > maxValue)
				throw new Error("超出范围值 " + maxValue);
			
			this._value = v;
			this._percent = _value / maxValue * 100;
			var w:Number = this._value / maxValue * _width;
			
			if(_progressBar != null)
				_progressBar.width = w;
			else
				progressBar.width = w;
			
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**	百分值，0-1 */		
		public function get percent():Number{		return _percent;	}
		public function set percent(value:Number):void
		{
			if(value < 0 || value > 100)
				throw new Error("超出范围百分值 " + 100);
			
			this._percent = value;
			this.value = (this._percent) * maxValue;
		}
		
		/**	@inhertDoc.	*/
		override public function set width(value:Number):void
		{
			this._width = value;
			
			if(_backgroundBar != null && _progressBar != null)
			{
				this._progressBar.width = this._width;
				this._backgroundBar.width = this._width;
			}
			else
			{
				progressBar.width = this._width;
				backgroundBar.width = this._width;
			}
			
			this.value = _value;
		}
		
		/**	@inhertDoc.	*/
		override public function set height(value:Number):void
		{
			this._height = value;
			if(_backgroundBar != null && _progressBar != null)
			{
				this._progressBar.height = this._height;
				this._backgroundBar.height = this._height;
			}
			else
			{
				progressBar.height = this._height;
				backgroundBar.height = this._height;
			}
		}
		
		/**	进度条颜色	 */		
		public function get progressColor():uint{		return this._progressColor;		}
		public function set progressColor(value:uint):void
		{
			this._progressColor = value;
			if(_progressBar != null)
				this._progressBar.color = this._progressColor;
		}
		
		/**	进度条背景颜色	 */		
		public function get backgroundColor():uint{		return this._backgroundColor;		}
		public function set backgroundColor(value:uint):void
		{
			this._backgroundColor = value;
			if(_backgroundBar != null)
				this._backgroundBar.color = this._backgroundColor;
		}
		
		/**	圆角大小	 */		
		public function get ellipse():Number{		return this._ellipse;		}
		public function set ellipse(value:Number):void
		{
			this._ellipse = value;
			if(_backgroundBar != null && _progressBar != null)
			{
				this._progressBar.ellipse = this._ellipse;
				this._backgroundBar.ellipse = this._ellipse;
			}
		}
		
		
	}
}