package org.coderepos.net.imap.events
{
    import flash.events.Event;

    public class IMAPResponseEvent extends Event
    {
        public static const RECEIVE:String = "receive";

        private var _data:*;

        public function IMAPResponseEvent(type:String, data:*,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            _data = data;
        }

        public function get data():*
        {
            return _data;
        }
    }
}
