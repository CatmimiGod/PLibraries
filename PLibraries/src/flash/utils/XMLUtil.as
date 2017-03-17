package flash.utils
{
	public class XMLUtil
	{
		
		public static function toObject(xml:Object, viewModel:Object = null):Object
		{
			var obj:Object = {};
			
			for each(var node:XML in xml.children())
			{
				var prop:String = node.localName();
				
				if(node.hasComplexContent())
				{
					obj[prop] = toObject(node, viewModel);
				}
				else
				{
					switch(node.@type.toString())
					{
						case "Number":
							obj[prop] = Number(xml[prop]);
						break;
						
						case "Array":
							//obj[prop] = String(
							break;
						
						case "Function":
							if(viewModel != null)
								obj[prop] = viewModel[xml[prop].toString()];
							break;
						
						default:
							obj[prop] = String(xml[prop]);
					}
					
				}
				
				//obj[prop] = node.hasComplexContent() ? toObject(node) : xml[prop];
			}
			
			return obj;
		}
	}
}