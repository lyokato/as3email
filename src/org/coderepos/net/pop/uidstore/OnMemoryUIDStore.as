package org.coderepos.net.pop.uidstore
{
    public class OnMemoryUIDStore implements IUIDStore
    {
        private var _records:Object;

        public function OnMemoryUIDStore()
        {
            _records = {};
        }

        public function load():void
        {

        }

        public function hasUID(uid:String):Boolean
        {
            return (uid in _records);
        }

        public function retrieveUIDTime(uid:String):Number
        {
            if (uid in _records)
                return _records[uid];
            return -1;
        }

        public function storeUID(uid:String):void
        {
            var t:Number = (new Date()).time;
            if (!(uid in _records))
                _records[uid] = t;
        }

        public function removeUID(uid:String):void
        {
            if (uid in _records)
                delete _records[uid];
        }

        public function save():void
        {

        }
    }
}

