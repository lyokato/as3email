package org.coderepos.net.smtp.commands
{
    import flash.utils.ByteArray;

    public class EHLO implements ISMTPCommand
    {
        private var _host:String;

        public function EHLO(host:String="localhost")
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
            return "EHLO " + _host + "\r\n";
        }
    }
}

