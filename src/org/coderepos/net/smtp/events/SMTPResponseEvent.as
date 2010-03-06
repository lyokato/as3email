package org.coderepos.net.smtp.events
{
    import flash.events.Event;
    import org.coderepos.net.smtp.SMTPResponse;

    public class SMTPResponseEvent extends Event
    {
        public static const RECEIVED:String = "smtp_received";

        private var _response:SMTPResponse;

        public function SMTPResponseEvent(type:String,
            response:SMTPResponse,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            _response = response;
            super(type, bubbles, cancelable);
        }

        public function get response():SMTPResponse
        {
            return _response;
        }

        override public function clone():Event
        {
            return new SMTPResponseEvent(type, _response, bubbles, cancelable);
        }
    }
}

