package org.coderepos.net.pop.uidstore
{
    public class NullUIDStore implements IUIDStore
    {
        public function NullUIDStore()
        {
        }

        public function load():void
        {

        }

        public function hasUID(uid:String):Boolean
        {
            return false;
        }

        public function retrieveUIDTime(uid:String):Number
        {
            return -1;
        }

        public function storeUID(uid:String):void
        {
        }

        public function removeUID(uid:String):void
        {

        }

        public function save():void
        {

        }
    }
}

