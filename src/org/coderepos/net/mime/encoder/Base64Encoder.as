package org.coderepos.net.mime.encoder
{
    import flash.utils.ByteArray;
    import com.hurlant.util.Base64;

    public class Base64Encoder implements IMIMEEncoder
    {
        public function Base64Encoder()
        {

        }

        public function get initial():String
        {
            return "B";
        }

        public function get encodingName():String
        {
            return "base64";
        }

        public function encode(src:ByteArray):String
        {
            return Base64.encodeByteArray(src);
        }

        public function decode(src:String):ByteArray
        {
            return Base64.decodeToByteArray(src);
        }
    }
}

