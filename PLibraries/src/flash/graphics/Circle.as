package flash.graphics
{
	/**
	 *	矢量图－圆 
	 * @author Administrator
	 */	
	public class Circle extends AbstractGraphics
	{
		/**
		 *	Constructor. 
		 */		
		public function Circle()
		{
		}
		
		/**
		 *	开始绘图 
		 */		
		override protected function updateDraw():void
		{
			super.updateDraw();
			
			this.graphics.beginFill(color, alpha);
			this.graphics.drawEllipse(0, 0, width, height);
			this.graphics.endFill();
		}
		
	}
}