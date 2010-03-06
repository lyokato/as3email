package org.coderepos.net.pop.events
{
    import flash.events.Event;
    import org.coderepos.net.pop.POPResponse;

    public class POPResponseEvent extends Event
    {
        public static const RECEIVED:String = "pop_received";

        private var _response:POPResponse;

        public var targetID:String;
        public var targetUID:String;

        public function POPResponseEvent(type:String,
            response:POPResponse,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            _response = response;
            super(type, bubbles, cancelable);
        }

        public function get response():POPResponse
        {
            return _response;
        }

        override public function clone():Event
        {
            return new POPResponseEvent(type, _response, bubbles, cancelable);
        }
    }
}


