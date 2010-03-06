package org.coderepos.net.smtp.commands
{
    import flash.utils.ByteArray;

    public class HELO implements ISMTPCommand
    {
        private var _host:String;

        public function HELO(host:String="localhost")
        {
            _host = host;
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
            return "HELO " + _host + "\r\n";
        }
    }
}
