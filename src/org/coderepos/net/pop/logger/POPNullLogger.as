package org.coderepos.net.pop.logger
{
    public class POPNullLogger implements IPOPLogger
    {
        public function POPNullLogger()
        {

        }

        public function logRequest(req:String):void
        {
            // do nothing
        }

        public function logResponse(res:String):void
        {
            // do nothing
        }

        public function logFormatError(src:String):void
        {

        }
    }
}
