package org.coderepos.net.mime.charset
{
    import flash.utils.ByteArray;
    import org.coderepos.text.encoding.Jcode;

    public class MIMEDefaultCharsetEncoder implements IMIMECharsetEncoder
    {
        public function MIMEDefaultCharsetEncoder()
        {

        }

        public function encode(utf8string:String, charset:String):ByteArray
        {
            charset = charset.toLowerCase();
            var result:ByteArray;
            switch (charset) {
                case "us-ascii":
                case "utf-8":
                    result = new ByteArray();
                    result.writeUTFBytes(utf8string);
                    result.position = 0;
                    break;
                case "euc-jp":
                    result = Jcode.to_euc(utf8string);
                    break;
                case "iso-2022-jp":
                case "iso-2022-jp-1":
                case "iso-2022-jp-2":
                case "iso-2022-jp-3":
                    result = Jcode.to_jis(Jcode.h2z(utf8string));
                    break;
                case "shift_jis":
                case "cp932":
                    result = Jcode.to_sjis(utf8string);
                    break;
                default:
                    result = new ByteArray();
                    result.writeMultiByte(utf8string, charset);
                    result.position = 0;
                    break;
            }
            return result;
        }

        public function decode(bytes:ByteArray, charset:String):String
        {
            charset = charset.toLowerCase();
            bytes.position = 0;
            var result:String;
            switch (charset) {
                case "us-ascii":
                case "utf-8":
                    result = bytes.readUTFBytes(bytes.bytesAvailable);
                    break;
                case "euc-jp":
                    result = Jcode.from_euc(bytes);
                    break;
                case "iso-2022-jp":
                case "iso-2022-jp-1":
                case "iso-2022-jp-2":
                case "iso-2022-jp-3":
                    result = Jcode.from_jis(bytes);
                    break;
                case "shift_jis":
                case "cp932":
                    result = Jcode.from_sjis(bytes);
                    break;
                default:
                    result = bytes.readMultiByte(bytes.bytesAvailable, charset);
                    break;
            }
            return result;
        }
    }
}

