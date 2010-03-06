package org.coderepos.net.smtp.logger
{
    public class SMTPTraceLogger implements ISMTPLogger
    {
        private var _reqPrefix:String;
        private var _resPrefix:String;

        public function SMTPTraceLogger(reqPrefix:String="", resPrefix:String="")
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
    }
}

