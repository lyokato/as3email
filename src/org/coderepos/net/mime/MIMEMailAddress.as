package org.coderepos.net.mime
{
    public class MIMEMailAddress
    {
        public static function parse(src:String):MIMEMailAddress
        {
            var address:String;
            var nick:String = null;

            var match:Array = src.match(/^\s*(.*[^\s]+)?\s*\<([^>]+)\>\s*$/);
            if (match != null) {
                nick    = match[1];
                address = match[2];
            } else {
                // XXX: TODO mail address format validation
                address = src;
            }
            return new MIMEMailAddress(address, nick);
        }

        private var _address:String;
        private var _nick:String;

        public function MIMEMailAddress(address:String, nick:String=null)
        {
            // XXX: TODO mail address format validation
            _address = address;
            _nick    = nick;
        }

        public function get address():String
        {
            return _address;
        }

        public function get nickname():String
        {
            return _nick;
        }

        public function valueOf():String
        {
            return (_nick == null)
                ? _address
                : _nick + " <" + _address + ">";
        }

        public function toString():String
        {
            return valueOf();
        }
    }
}

