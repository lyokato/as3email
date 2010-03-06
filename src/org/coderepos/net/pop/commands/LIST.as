package org.coderepos.net.pop.commands
{
    import flash.utils.ByteArray;

    public class LIST implements IPOPCommand
    {
        public function LIST()
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
            var command:String = "LIST\r\n";
            return command;
        }

        public function get supportsMultiLineResponse():Boolean
        {
            return true;
        }
    }
}

