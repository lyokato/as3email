package org.coderepos.net.imap
{
    public class TagGenerator
    {
        private var _prefix:String;
        private var _digit:uint;
        private var _current:uint;

        public function TagGenerator(prefix:String, digit:uint)
        {
            _prefix  = prefix;
            _digit   = digit;
            _current = 0;
        }

        public function generate():String
        {
            _current++;
            var n:String = String(_current);
            if (n.length > _digit) {
                n = n.substring(n.length - 4);
                _current = uint(n);
            } else if (n.length < _digit) {
                while (n.length < 4)
                    n = "0" + n;
            }
            return _prefix + n;
        }
    }
}

