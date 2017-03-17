package flash.controller
{
	/**
	 *	[全局方法]执行模型或视图函数
	 *	@param viewModel:Object		视图或模型对象
	 *	@param funcOrName:String	函数或是函数名
	 *	@param ...args	函数参数
	 */
	internal function executingFunctions(viewModel:Object, funcOrName:Object, args:Array = null):void
	{
		if(funcOrName is Function)
		{
			FunctionUtil.executingFunction(viewModel, funcOrName as Function, args);
		}
		else if(funcOrName is String)
		{
			FunctionUtil.executingFunctionName(viewModel, funcOrName.toString(), args);
		}
		else
		{
			throw new ArgumentError("executingFunctions::funcOrName类型错误。");
		}
	}
}

final class FunctionUtil
{
	/**
	 *  执行函数名
	 */
	public static function executingFunctionName(viewModel:Object, funcName:String, args:Array = null):void
	{
		if(viewModel.hasOwnProperty(funcName))
		{
			var argsLen:int = args == null ? 0 : args.length;
			
			switch(argsLen)
			{
				case 0:
					viewModel[funcName]();
					break;
				
				case 1:
					viewModel[funcName](args[0]);
					break;
				
				case 2:
					viewModel[funcName](args[0], args[1]);
					break;
				
				case 3:
					viewModel[funcName](args[0], args[1], args[2]);
					break;
				
				case 4:
					viewModel[funcName](args[0], args[1], args[2], args[3]);
					break;
				
				case 5:
					viewModel[funcName](args[0], args[1], args[2], args[3], args[4]);
					break;
				
				case 6:
					viewModel[funcName](args[0], args[1], args[2], args[3], args[4], args[5]);
					break;
				
				case 7:
					viewModel[funcName](args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
					break;
				
				case 8:
					viewModel[funcName](args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
					break;
				
				case 9:
					viewModel[funcName](args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);
					break;
				
				default:
					throw new ArgumentError("executingFunctions()函数参数超出范围 9.");
			}
		}
		else
		{
			trace("executingFunctions() 视图或模型不存在方法名 " + funcName + ".");
		}
	}
	
	/**
	 *  执行函数
	 */
	public static function executingFunction(viewModel:Object, func:Function, args:Array = null):void
	{
		var argsLen:int = args == null ? 0 : args.length;
		switch(argsLen)
		{
			case 0:
				func();
				break;
			
			case 1:
				func(args[0]);
				break;
			
			case 2:
				func(args[0], args[1]);
				break;
			
			case 3:
				func(args[0], args[1], args[2]);
				break;
			
			case 4:
				func(args[0], args[1], args[2], args[3]);
				break;
			
			case 5:
				func(args[0], args[1], args[2], args[3], args[4]);
				break;
			
			case 6:
				func(args[0], args[1], args[2], args[3], args[4], args[5]);
				break;
			
			case 7:
				func(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
				break;
			
			case 8:
				func(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
				break;
			
			case 9:
				func(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);
				break;
			
			default:
				throw new ArgumentError("executingFunctions()函数参数超出范围 9.");
		}
	}

}