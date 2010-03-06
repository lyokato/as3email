package org.coderepos.net.smtp.commands
{
    import flash.utils.ByteArray;

    public class DATA implements ISMTPCommand
    {
        public function DATA()
        {
        }

        public function toByteArray():ByteArray
        {
            var b:ByteArray = new ByteArray();
            b.writeUTFBytes(valueOf());
            b.position = 0;
            return b;
        }

        public function valueOf():String
        {
            return "DATA\r\n";
        }
    }
}

