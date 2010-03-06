package org.coderepos.net.pop.commands
{
    import flash.utils.ByteArray;

    public class STAT implements IPOPCommand
    {

        public function STAT(username:String)
        {
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
            var command:String = "STAT\r\n";
            return command;
        }

        public function get supportsMultiLineResponse():Boolean
        {
            return false;
        }
    }
}

