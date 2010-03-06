package org.coderepos.net.pop.commands
{
    import flash.utils.ByteArray;

    public class USER implements IPOPCommand
    {
        private var _username:String;

        public function USER(username:String)
        {
            _username  = username;
        }

        public function get targetID():String
        {
            return null;
        }

        public function get targetUID():String
        {
            return null;
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
            var command:String = "USER ";
            command += _username;
            command += "\r\n";
            return command;
        }

        public function get supportsMultiLineResponse():Boolean
        {
            return false;
        }
    }
}

