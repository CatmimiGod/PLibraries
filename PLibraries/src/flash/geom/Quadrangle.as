package flash.geom
{
	/**
	 *	四边形对象 
	 * 对应点如下：
	 * 		a———————————b
	 * 		|	.p		|
	 * 		|			|
	 * 		c———————————d
	 * 对应边为，ab边，bd边，dc边， ca边，中点点为p，内边分为pa,pc,pb,pd;垂直边pab,pbd,pdc,pca
	 * 
	 * @author Administrator
	 */	
	public class Quadrangle
	{
		/**	四边形左上角点	*/
		public var a:Point = new Point();
		
		/**	四边形右上角点	*/
		public var b:Point = new Point();
		
		/**	四边形左下角点	*/
		public var c:Point = new Point();
		
		/**	四边形右上角点	*/
		public var d:Point = new Point();
		
		/**
		 *	Constructor. 四边形
		 */		
		public function Quadrangle(pa:Point, pb:Point, pc:Point, pd:Point)
		{
			if(pa != null)	a = pa;
			if(pb != null)	b = pb;
			if(pc != null)	c = pc;
			if(pd != null)	d = pd;
		}
		
		/**
		 *	返回一个新的 Quadrangle 对象，其a、b、c、d 属性的值与原始 Quadrangle 对象的对应值相同。 
		 * @return 
		 */		
		public function clone():Quadrangle
		{
			return new Quadrangle(a, b, c, d);
		}
		
		/**
		 *	指定的点p是否在四边形范围内，或四边形是否包含指定的点。
		 * @param p:Point	指定的一个点
		 * @return 	返回点是否在四边形范围内。
		 */		
		public function contains(p:Point):Boolean
		{
			/**
			 * @internal.
			 * 将四边形分解为四个无交集的三角形，其计算面积总和
			 */
			var pa:Number = triangleArea(p, a, b) + triangleArea(p, a, c) + triangleArea(p, b, d) + triangleArea(p, d, c);
			
			return area == pa;
		}
				
		/**
		 *	返回四边形的面积 
		 * @return 
		 */		
		public function get area():Number
		{ 
			/**
			 * @internal.
			 * 将四边形分解为两个无交集的三角形，其计算面积总和
			 */
			return triangleArea(a, b, d) + triangleArea(a, c, d);
		}
		
		/**
		 *  @copy #Object.toString()
		 */
		public function toString():String
		{
			return "[Quadrangle(a=" + a + ", b=" + b + ", c=" + c + ", d=" + d + ", area=" + area + ")]";
		}
		
		/**
		 *	三角形面积计算 
		 * @param a:Point	三角形点A
		 * @param b:Point	三角形点B
		 * @param c:Point	三角形点C
		 * @return 返回三角形面积
		 */		
		[inline]
		public static function triangleArea(a:Point, b:Point, c:Point):Number
		{
			return Math.abs((a.x * b.y + b.x * c.y + c.x * a.y - b.x * a.y - c.x * b.y - a.x * c.y) / 2.0);
		}
		
		/**
		 * 计算指定的点p与点a,b的垂直距离 
		 * @param p
		 * @param a
		 * @param b
		 * @return 
		 */		
		[inline]
		public static function distance(p:Point, a:Point, b:Point):Number
		{
			//trace(p, a, b);
			
			//计算三边长度
			var pa:Number = Point.distance(p, a);
			var pb:Number = Point.distance(p, b);
			var ab:Number = Point.distance(a, b);
			//trace(pa, pb, ab)
			
			//计算弧度	用余弦定理	计算反余弦值
			var radianA:Number = Math.acos((pa * pa + ab * ab - pb * pb) / (2 * pa * ab));			
			var radianB:Number = Math.acos((pb * pb + ab * ab - pa * pa) / (2 * pb * ab));
			var radianP:Number = Math.acos((pa * pa + pb * pb - ab * ab) / (2 * pa * pb));
			//trace(radianA, radianB, radianP);
			
			//或角度
			//var angleA:Number = radianA * 180 / Math.PI;
			//var angleB:Number = radianB * 180 / Math.PI;
			//var angleP:Number = radianP * 180 / Math.PI;			
			//trace(angleA, angleB, angleP);
			
			//计算直角边
			var pab:Number = pa * Math.sin(radianA);
			//trace(pab);
			
			return pab;
		}
		
	}
}