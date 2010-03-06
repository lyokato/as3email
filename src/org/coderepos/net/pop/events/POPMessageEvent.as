package org.coderepos.net.pop.events
{
    import flash.events.Event;
    import org.coderepos.net.mime.MIMEMessage;

    public class POPMessageEvent extends Event
    {
        public static const RETRIEVED:String = "pop_msg_retrieved";
        public static const DELETED:String   = "pop_msg_deleted";

        private var _message:MIMEMessage;

        public var targetID:String;
        public var targetUID:String;

        public function POPMessageEvent(type:String,
            message:MIMEMessage=null,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            _message = message;
            super(type, bubbles, cancelable);
        }

        public function get message():MIMEMessage
        {
            return _message;
        }

        override public function clone():Event
        {
            return new POPMessageEvent(type, _message, bubbles, cancelable);
        }
    }
}

