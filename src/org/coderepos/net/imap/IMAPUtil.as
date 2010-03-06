package org.coderepos.net.imap
{
    import flash.utils.ByteArray;
    import com.hurlant.util.Base64;

    public class IMAPUtil
    {
        public static function bytesToString(b:ByteArray):String
        {
            var pos:int = b.position;
            b.position = 0;
            var s:String = b.readUTFBytes(b.bytesAvailable);
            b.position = pos;
            return s;
        }

        public static function stringToBytes(s:String):ByteArray
        {
            var b:ByteArray = new ByteArray();
            b.writeUTFBytes(s);
            b.position = 0;
            return b;
        }

        public static function copyBytes(b:ByteArray):ByteArray
        {
            var bytes:ByteArray = new ByteArray();
            bytes.readBytes(b, 0, b.length);
            bytes.position = 0;
            return bytes;
        }

    }
}

