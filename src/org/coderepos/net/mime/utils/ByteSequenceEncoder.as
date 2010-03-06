package org.coderepos.net.mime.utils
{
    import flash.utils.ByteArray;

    public class ByteSequenceEncoder
    {
        /*
            var bytes:ByteArray = charsetEncoder.encode(src, charset);
            var encoded:String = ByteSequenceEncoder.encode(bytes);
        */
        public static function encode(bytes:ByteArray):String
        {
            bytes.position = 0;

            var result:String = "";
            var c:uint;

            while (bytes.bytesAvailable > 0) {

                c = bytes.readUnsignedByte();

                /*
                 not attribute-char
                 [RFC2231]
                 attribute-char := <any (US-ASCII) CHAR except SPACE, CTLs, "*", "'", "%", or tspecials>
                 [RFC2045]
                 tspecials :=  "(" / ")" / "<" / ">" / "@" /
                   "," / ";" / ":" / "\" / <">
                   "/" / "[" / "]" / "?" / "="
                */
                if (c > 0x20
                    && c != 0x22
                    && c != 0x24 // escape '&' ?
                    && c != 0x25
                    && c != 0x2c
                    && c != 0x2f
                    && !(c >= 0x27 && c <= 0x2a)
                    && !(c >= 0x3a && c <= 0x40)
                    && !(c >= 0x5b && c <= 0x5d)
                    && c < 0x7f) {
                    result += String.fromCharCode(c);
                } else {
                    result += "%" + Number(c).toString(16).toUpperCase();
                }
            }
            return result;
        }

        /*
            var bytes:ByteArray = ByteSequenceEncoder.decode(encodedString);
            var utf8string:String = charsetEncoder.decode(bytes, charset);
        */
        public static function decode(src:String):ByteArray
        {
            var char:String;
            var i:int = 0;
            var len:int = src.length;
            var buf:ByteArray = new ByteArray();
            while (i < len) {
                char = src.charAt(i++);
                if (char == "%" && i + 2 <= len) {
                    var next:String = src.substring(i, i+2);
                    i += 2;
                    if (next.match(/^[0-9a-fA-F]{2}$/) != null) {
                        buf.writeByte(parseInt(next, 16));
                    } else {
                        buf.writeUTFBytes(char + next);
                    }
                } else {
                    buf.writeUTFBytes(char);
                }
            }
            buf.position = 0;
            return buf;
        }
    }
}

