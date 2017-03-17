package flash.model
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * URLLoaderModel
	 *	 数据提交模型，请跟据不同数据协议继承此模型或参考此模型修改
	 * @author Administrator
	 */	
	public class SubmitDataModel
	{
		private var _loader:URLLoader;
		
		/**	URLRequest	*/
		protected var _request:URLRequest;
		
		/**	结果处理函数	 */
		protected var _result:Function;
		/**	状态处理函数	 */
		protected var _status:Function;
		
		/**
		 *	数据提交 
		 * @param result:Function	
		 * @param status:Function	
		 */		
		public function SubmitDataModel()
		{
			initialize();
		}
		
		/**
		 *	清除引用
		 */		
		public function dispose():void
		{
			_loader.close();
			_loader.removeEventListener(Event.COMPLETE, onURLLoaderEventHandler);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, onURLLoaderEventHandler);
			_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onURLLoaderEventHandler);
			
			_loader = null;
			_request = null;
			
			_result = null;
			_status = null;
		}
		
		/**
		 *	initialize. 
		 */		
		protected function initialize():void
		{
			//URLRequest
			_request = new URLRequest();
			
			//URLLoader
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onURLLoaderEventHandler, false, 0, true);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onURLLoaderEventHandler, false, 0, true);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onURLLoaderEventHandler, false, 0, true);
		}
		
		private function onURLLoaderEventHandler(e:Event):void 
		{
			switch(e.type)
			{
				case Event.COMPLETE:
					var data:Object = e.target.data;
					break;
				
				case IOErrorEvent.IO_ERROR:
					if(_status != null)
						_status(SubmitDataStatus.IO_ERROR);
					break;
				
				case SecurityErrorEvent.SECURITY_ERROR:
					if(_status != null)
						_status(SubmitDataStatus.SECURITY_ERROR);
					break;
			}
		}
		
		/**
		 *	 分析数据，这里跟据实际数据协议分析
		 * @param data:Object
		 */		
		protected function analyseData(data:Object):void
		{
			if(_status != null)
				_status(SubmitDataStatus.SUCCESS);
			
			if(_result != null)
				_result(data);
		}
		
		/**
		 * 
		 * @param address
		 * @param data
		 * 
		 */		
		public function submit(address:String, data:Object = null):void
		{
			if(data != null)
				_request.data = data;	
			
			_request.url = address;					
			_request.contentType = "json/text";
			
			_loader.load(_request);
		}
		
		/**
		 *	 
		 * @param result
		 * @param status
		 * 
		 */		
		public function setResponder(result:Function, status:Function):void
		{
			if(result == null || status == null)
				throw new ArgumentError("SubmitData::result与status函数不能为空。");
			
			_result = result;
			_status = status;
		}
		
	}
}
