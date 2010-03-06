package org.coderepos.net.pop.commands
{
    import flash.utils.ByteArray;

    public class DELE implements IPOPCommand
    {
        private var _id:String;
        private var _uid:String;

        public function DELE(id:String, uid:String=null)
        {
            _id  = id;
            _uid = uid;
        }

        public function get targetID():String
        {
            return _id;
        }

        public function get targetUID():String
        {
            return _uid;
        }

        public function toByteArray():ByteArray
        {
            var bytes:ByteArray = new ByteArray();
            bytes.writeUTFBytes(valueOf());
            bytes.position = 0;
            return bytes;
        }

        public function valueOf():String
        {
            var command:String = "DELE ";
            command += _id;
            command += "\r\n";
            return command;
        }

        public function get supportsMultiLineResponse():Boolean
        {
            return false;
        }
    }
}

