package org.coderepos.net.smtp.events
{
    import flash.events.Event;
    import org.coderepos.net.smtp.SMTPResponse;

    public class SMTPErrorEvent extends Event
    {
        public static const ERROR:String = "smtp_error";
        public static const TIMEOUT:String = "smtp_timeout";

        private var _message:String;

        public function SMTPErrorEvent(type:String,
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
            return new SMTPErrorEvent(type, _message, bubbles, cancelable);
        }
    }
}

