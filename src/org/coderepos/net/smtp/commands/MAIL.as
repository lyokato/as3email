package org.coderepos.net.smtp.commands
{
    import flash.utils.ByteArray;
    import org.coderepos.net.mime.MIMEMailAddress;

    public class MAIL implements ISMTPCommand
    {
        private var _address:MIMEMailAddress;

        public function MAIL(address:MIMEMailAddress)
        {
            _address = address;
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
            return "MAIL FROM: <" + _address.address + ">\r\n";
        }
    }
}

