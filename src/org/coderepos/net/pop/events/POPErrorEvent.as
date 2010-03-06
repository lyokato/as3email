package org.coderepos.net.pop.events
{
    import flash.events.Event;

    public class POPErrorEvent extends Event
    {
        public static const ERROR:String   = "pop_error";
        public static const TIMEOUT:String = "pop_timeout";

        private var _message:String;

        public function POPErrorEvent(type:String,
            message:String="",
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            _message = message;
            super(type, bubbles, cancelable);
        }

        public function get message():String
        {
            return _message;
        }

        override public function clone():Event
        {
            return new POPErrorEvent(type, _message, bubbles, cancelable);
        }
    }
}

