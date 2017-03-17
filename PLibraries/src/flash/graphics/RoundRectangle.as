package flash.graphics
{
	import flash.geom.Rectangle;

	/**
	 *	矢量绘图，矩形 
	 * @author Administrator
	 */	
	public class RoundRectangle extends AbstractGraphics
	{
		private var _ellipse:Number = 0;
		
		/**
		 *	Constructor. 
		 */		
		public function RoundRectangle()
		{
		}
		
		/**
		 *	开始绘图 
		 */		
		override protected function updateDraw():void
		{
			super.updateDraw();
			
			this.graphics.beginFill(color, alpha);
			this.graphics.drawRoundRect(0, 0, width, height, _ellipse, _ellipse);
			this.graphics.endFill();
			
			if(_ellipse != 0 && width > 0 && height > 0 && this.scale9Grid == null)
			{
				var rect:Rectangle = new Rectangle(_ellipse, 1, width - (_ellipse * 2), height - 2);
				//trace(rect);
				//this.graphics.lineStyle(.1, 0xFF0000, 1, false, "none");
				//this.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
				
				this.scale9Grid = rect;
			}
		}
		
		/**	绘制矩形的圆角的椭圆宽高度	*/		
		public function get ellipse():Number{		return this._ellipse;	}
		public function set ellipse(value:Number):void
		{
			this._ellipse = value;
			updateDraw();
		}
		
		
	}
}