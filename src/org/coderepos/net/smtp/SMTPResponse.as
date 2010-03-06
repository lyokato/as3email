package org.coderepos.net.smtp
{
    public class SMTPResponse
    {
        private var _code:uint;
        private var _lines:Array;

        public function SMTPResponse(code:uint, lines:Array)
        {
            _code  = code;
            _lines = lines;
        }

        public function get isError():Boolean
        {
            return (_code >= 400);
        }

        public function get code():uint
        {
            return _code;
        }

        public function get lines():Array
        {
            return _lines;
        }

        public function valueOf():String
        {
            var code:String = String(_code);
            var value:String = "";
            var len:int = _lines.length;
            for (var i:int = 0; i < len; i++) {
                value += code;
                if (i == len - 1)
                    value += " ";
                else
                    value += "-";
                value += _lines[i];
                value += "\r\n";
            }
            return value;
        }
    }
}

