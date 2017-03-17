package flash.graphics
{
	import flash.display.Shape;
	
	/**
	 *	抽象矢量绘图对象 
	 * @author Administrator
	 */	
	public class AbstractGraphics extends Shape
	{
		private var _width:Number = 100;
		private var _height:Number = 100;
		
		private var _color:uint = 0x999999;
		private var _alpha:Number = 1;
		
		private var _thickness:Number = 0;
		private var _lineColor:uint = 0xFF0000;
		private var _lineAlpha:Number = 1.0;
		
		/**
		 *	Constructor.	不可实例化，只可继承 
		 */		
		public function AbstractGraphics()
		{
			updateDraw();
		}
		
		/**
		 *	开始绘图 
		 */		
		protected function updateDraw():void
		{
			this.graphics.clear();
			
			if(this._thickness > 0)
				this.graphics.lineStyle(_thickness, _lineColor, _lineAlpha, false, "none");
		}
		
		
		/**	绘制矢量图形的颜色	*/		
		public function get color():uint{		return this._color;	}
		public function set color(value:uint):void
		{
			this._color = value;
			updateDraw();
		}
		
		/**	绘制矢量图形的边线粗细	*/		
		public function get thickness():Number{	return this._thickness;	}
		public function set thickness(value:Number):void
		{
			this._thickness = value;
			updateDraw();
		}
		
		/**	绘制矢量图形的边线颜色	*/
		public function get lineColor():uint{		return this._lineColor;	}
		public function set lineColor(value:uint):void
		{
			this._lineColor = value;
			updateDraw();
		}
		
		/**	绘制矢量图形的边线的透明度	*/
		public function get lineAlpha():Number{		return this._lineAlpha;	}
		public function set lineAlpha(value:Number):void
		{
			this._lineAlpha = value;
			updateDraw();
		}
		
		/**	绘制矢量图形的颜色	*/		
		override public function get alpha():Number{		return this._alpha;	}
		override public function set alpha(value:Number):void
		{
			this._alpha = value;
			updateDraw();
		}
		
		/**	绘制矢量图形的宽度	*/
		override public function get width():Number{		return this._width;	}
		override public function set width(value:Number):void
		{
			this._width = value;
			updateDraw();
		}
		
		/**	绘制矢量图形的宽度	*/
		override public function get height():Number{		return this._height;	}
		override public function set height(value:Number):void
		{
			this._height = value;
			updateDraw();
		}
		
		/**
		 *	设置绘图对象尺寸大小 
		 * @param width
		 * @param height
		 */		
		public function setSize(width:Number, height:Number):void
		{
			this._width = width;
			this._height = height;
			
			updateDraw();
		}
		
		/**
		 *	设置绘图对象的颜色 
		 * @param color
		 * @param alpha
		 */		
		public function setColor(color:uint, alpha:Number):void
		{
			this._color = color;
			this.alpha = alpha;
			updateDraw();
		}
		
		/**
		 *	设置矢量图形的边线样式 
		 * @param thickness
		 * @param color
		 * @param alhpa
		 */		
		public function setLineStyle(thickness:Number, color:uint, alhpa:Number = 1.0):void
		{
			this._thickness = thickness;
			this._lineColor = color;
			this._lineColor = alpha;
			
			updateDraw();
		}
		
		
	}
}