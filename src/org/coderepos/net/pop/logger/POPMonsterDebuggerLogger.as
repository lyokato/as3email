package org.coderepos.net.pop.logger
{
    import nl.demonsters.debugger.MonsterDebugger;

    public class POPMonsterDebuggerLogger implements IPOPLogger
    {
        private var _reqPreifx;
        private var _resPrefix;

        public function POPMonsterDebuggerLogger(reqPrefix:String="", resPrefix:String="")
        {
            _reqPrefix = reqPrefix;
            _resPrefix = resPrefix;
        }

        public function logRequest(req:String):void
        {
            if (_reqPrefix != null && _reqPrefix.length > 0)
                MonsterDebugger.trace(_reqPreifx);
            MonsterDebugger.trace(req);
        }

        public function logResponse(res:String):void
        {
            if (_resPrefix != null && _resPrefix.length > 0)
                MonsterDebugger.trace(_resPreifx);
            MonsterDebugger.trace(res);
        }

        public function logFormatError(src:String):void
        {

        }
    }
}

