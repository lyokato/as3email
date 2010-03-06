package org.coderepos.net.imap.events
{
    import flash.events.Event;

    public class IMAPErrorEvent extends Event
    {
        public static const PARSE_ERROR:String = "parseError";

        private var _message:String;

        public function IMAPErrorEvent(type:String, message:String="",
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            _message = message;
        }

        public function get message():*
        {
            return _message;
        }
    }
}
