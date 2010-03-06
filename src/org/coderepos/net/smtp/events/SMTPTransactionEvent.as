package org.coderepos.net.smtp.events
{
    import flash.events.Event;
    import org.coderepos.net.smtp.SMTPResponse;

    public class SMTPTransactionEvent extends Event
    {
        public static const COMPLETED:String = "smtp_txn_completed";

        private var _response:SMTPResponse;

        public function SMTPTransactionEvent(type:String,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }

        override public function clone():Event
        {
            return new SMTPTransactionEvent(type, bubbles, cancelable);
        }
    }
}

