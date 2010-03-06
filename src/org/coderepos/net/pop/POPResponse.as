package org.coderepos.net.pop
{
    import flash.utils.ByteArray;

    public class POPResponse
    {
        public static const OK:String  = "+OK";
        public static const ERR:String = "-ERR";

        private var _type:String;
        private var _status:String;
        private var _data:ByteArray;

        public var targetID:String;
        public var targetUID:String;

        public function POPResponse(type:String, status:String="",
            data:ByteArray=null)
        {
            _type   = type;
            _status = status;
            _data   = data;
        }

        public function get isError():Boolean
        {
            return (_type == ERR);
        }

        public function get type():String
        {
            return _type;
        }

        public function get status():String
        {
            return _status;
        }

        public function get data():ByteArray
        {
            return _data;
        }

        public function valueOf():String
        {
            var value:String = _type;

            if (_status.length > 0)
                value += " " + _status;

            /*
            if (_data != null) {
                value += "\r\n";
                value += _data;
            }
            */

            return value;
        }

        public function toString():String
        {
            return valueOf();
        }
    }
}

