package
{
	/**
	 * 栈集合
	 *	一种以后进先出(Last In First Out, LIFO)原则工作的集合，集合中最后增加的一个元素会最先从集合中移出 
	 * @author Administrator
	 */	
	public final dynamic class Stack
	{
		private var arr:Array = ["a", "b", "c", "d"];
		
		public function Stack()
		{
			var len:int = 4;
			for(var i:int = 0; i < len; i ++)
			{
				this[i] = arr[i];
			}
		}
		
		public function copyFrom(obj:*, count:uint = 1):void
		{
			
		}
		
		/**
		 *	 向栈中添加变量（进栈）
		 * @return 
		 * 
		 */		
		public function push():void
		{
			
		}
		
		/**
		 *	向栈中获取变量（出栈），变量会移出栈 
		 * 
		 */		
		public function pop():void
		{
			
		}
		
		/**
		 *	获取栈中最后一个进栈的变量，变量仍保留在栈中而不出栈 
		 * 
		 */		
		public function peek():void
		{
			
		}
	}
	
}

/**
 *	一种以先进先出(First In First Out, FIFO)原则工作的集合，集合中最先进入的一个元素会最先从集合中移出 
 * @author Administrator
 * 
 */
class Queue
{
	public function Queue()
	{
		
	}
}