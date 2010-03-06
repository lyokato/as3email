package org.coderepos.net.pop.events
{
    import flash.events.Event;

    public class POPTransactionEvent extends Event
    {
        public static const AUTHENTICATED:String = "pop_txn_authenticated";
        public static const COMPLETED:String     = "pop_txn_completed";
        public static const RETRIEVED:String     = "pop_txn_retrieved";
        public static const DELETED:String       = "pop_txn_deleted";

        public function POPTransactionEvent(type:String,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }

        override public function clone():Event
        {
            return new POPTransactionEvent(type, bubbles, cancelable);
        }

    }
}

