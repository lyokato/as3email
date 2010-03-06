package org.coderepos.net.mime.encoder
{
    import flash.utils.ByteArray;

    public class ByteEncoder implements IMIMEEncoder
    {
        public function ByteEncoder()
        {

        }

        public function get initial():String
        {
            return null;
        }

        public function get encodingName():String
        {
            return "bytes";
        }

        public function encode(src:ByteArray):String
        {
            src.position = 0;
            return src.readUTFBytes(src.length);
        }

        public function decode(src:String):ByteArray
        {
            var b:ByteArray = new ByteArray();
            b.writeUTFBytes(src);
            b.position = 0;
            return b;
        }
    }
}

