package org.coderepos.net.mime.mediatype
{
    public class MediaType
    {
        private var _type:String;
        private var _params:Object;

        public function MediaType(type:String)
        {
            _type   = type;
            _params = {};
        }

        public function get type():String
        {
            return _type;
        }

        public function set type(t:String):void
        {
            _type = t;
        }

        public function addParam(key:String, value:String):void
        {
            _params[key] = value;
        }

        public function hasParam(key:String):Boolean
        {
            return (key in _params);
        }

        public function getParam(key:String):String
        {
            return (key in _params) ? _params[key] : null;
        }

        public function valueOf():String
        {
            var value:String = _type;
            var pairs:Array = [];

            for (var prop:String in _params)
                pairs.push(prop + "=\"" + _params[prop] + "\"");

            if (pairs.length > 0)
                value += "; " + pairs.join("; ");

            return value;
        }

    }
}

