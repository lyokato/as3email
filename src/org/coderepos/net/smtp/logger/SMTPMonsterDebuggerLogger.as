package org.coderepos.net.smtp.logger
{
    import nl.demonsters.debugger.MonsterDebugger;

    public class SMTPMonsterDebuggerLogger implements ISMTPLogger
    {
        private var _reqPrefix:String;
        private var _resPrefix:String;

        public function SMTPMonsterDebuggerLogger(reqPrefix:String="", resPrefix:String="")
        {
            _reqPrefix = reqPrefix;
            _resPrefix = resPrefix;
        }

        public function logRequest(req:String):void
        {
            if (_reqPrefix != null && _reqPrefix.length > 0)
                MonsterDebugger.trace(_reqPrefix);
            MonsterDebugger.trace(req);
        }

        public function logResponse(res:String):void
        {
            if (_resPrefix != null && _resPrefix.length > 0)
                MonsterDebugger.trace(_resPrefix);
            MonsterDebugger.trace(res);
        }
    }
}

