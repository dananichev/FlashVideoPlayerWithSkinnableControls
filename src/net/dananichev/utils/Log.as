package net.dananichev.utils
{
	import flash.external.ExternalInterface;
	
	public class Log
	{

		public function Log() {}

        public function WriteLine(message : String) : void {
            outputlog("INFO: ", message);
        }

        /** Log a message to the console. **/
        private static function outputlog(level : String, message : String) : void {
            if (ExternalInterface.available)
                ExternalInterface.call('console.log', level + message);
            else trace(level + message);
        }
	}

}