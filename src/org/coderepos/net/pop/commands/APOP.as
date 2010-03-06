package org.coderepos.net.pop.commands
{
    import flash.utils.ByteArray;

    import com.hurlant.crypto.Crypto;
    import com.hurlant.crypto.hash.IHash;
    import com.hurlant.util.Hex;

    public class APOP implements IPOPCommand
    {
        private var _challenge:String;
        private var _username:String;
        private var _password:String;

        public function APOP(challenge:String, username:String, password:String)
        {
            _challenge = challenge;
            _username  = username;
            _password  = password;
        }

        public function get targetID():String
        {
            return null;
        }

        public function get targetUID():String
        {
            return null;
        }

        public function genResponse():String
        {
            var hasher:IHash = Crypto.getHash("md5");
            var bytes:ByteArray = new ByteArray();
            bytes.writeUTFBytes(_challenge + _password);
            bytes.position = 0;
            return Hex.fromArray(hasher.hash(bytes));
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
            var command:String = "APOP ";
            command += _username;
            command += " ";
            command += genResponse();
            command += "\r\n";
            return command;
        }

        public function get supportsMultiLineResponse():Boolean
        {
            return false;
        }
    }
}

