package org.coderepos.net.pop.logger
{
    public class POPTraceLogger implements IPOPLogger
    {
        private var _reqPrefix:String;
        private var _resPrefix:String;

        public function POPTraceLogger(reqPrefix:String="", resPrefix:String="")
        {
            _reqPrefix = reqPrefix;
            _resPrefix = resPrefix;
        }

        public function logRequest(req:String):void
        {
            if (_reqPrefix != null && _reqPrefix.length > 0)
                trace(_reqPrefix);
            trace(req);
        }

        public function logResponse(res:String):void
        {
            if (_resPrefix != null && _resPrefix.length > 0)
                trace(_resPrefix);
            trace(res);
        }

        public function logFormatError(src:String):void
        {
        }
    }
}

