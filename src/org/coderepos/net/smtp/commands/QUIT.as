package org.coderepos.net.smtp.commands
{
    import flash.utils.ByteArray;

    public class QUIT implements ISMTPCommand
    {
        public function QUIT()
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
            return "QUIT\r\n";
        }
    }
}

