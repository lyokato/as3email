package org.coderepos.net.mime.utils
{
    import flash.utils.ByteArray;
    import org.coderepos.net.mime.mediatype.IMediaTypeLineDecoder;
    import org.coderepos.net.mime.charset.IMIMECharsetEncoder;

    public class RFC2231Decoder implements IMediaTypeLineDecoder
    {
        private var _charsetEncoder:IMIMECharsetEncoder;

        public function RFC2231Decoder(charsetEncoder:IMIMECharsetEncoder)
        {
            _charsetEncoder = charsetEncoder;
        }

        public function decodeLine(str:String):String
        {
            var match:Array = str.match(/^([^\']+)\'([^\']+)?\'(.+)$/);
            if (match == null)
                return str;
            var enc:String  = match[1].toUpperCase();
            var lang:String = match[2];
            var data:String = match[3];

            var bytes:ByteArray = ByteSequenceEncoder.decode(data)
            return _charsetEncoder.decode(bytes, enc);
        }
    }
}

