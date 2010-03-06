package org.coderepos.net.mime.utils
{
    import flash.utils.ByteArray;
    import org.coderepos.net.mime.charset.IMIMECharsetEncoder;
    import org.coderepos.net.mime.encoder.IMIMEEncoder;
    import org.coderepos.net.mime.encoder.Base64Encoder;

    public class HeaderValueEncoder
    {
        private var _lineLength:uint;
        private var _charsetEncoder:IMIMECharsetEncoder;
        private var _mimeEncoder:IMIMEEncoder;
        /*
            var encoder:HeaderValueEncoder =
                new HeaderValueEncoder(new MIMEDefaultCharsetEncoder(), new Base64Encoder(), 26);
            var headerValue:String = encoder.encode( utf8string, "ISO-2022-JP" );

            // encoder.encode( utf8string );
            // // if you ommit charset, this is same as
            // encoder.encode( utf8string, "UTF-8" );
        */
        public function HeaderValueEncoder(charsetEncoder:IMIMECharsetEncoder,
            mimeEncoder:IMIMEEncoder=null, lineLength:uint=26)
        {
            _lineLength     = lineLength;
            _charsetEncoder = charsetEncoder;
            _mimeEncoder    = mimeEncoder;
            if (_mimeEncoder)
                _mimeEncoder = new Base64Encoder();
        }

        public function encode(utf8value:String, charset:String="UTF-8"):String
        {
            // fold by length you set
            var origin:String = utf8value;
            var results:Array = [];
            while (origin.length > _lineLength) {
                results.push(encodeLine(origin.substring(0, _lineLength), charset));
                origin = origin.substring(_lineLength);
            }
            if (origin.length > 0)
                results.push(encodeLine(origin, charset));
            return results.join("\r\n ");
        }

        public function encodeLine(line:String, charset:String):String
        {
            var arr:ByteArray = _charsetEncoder.encode(line, charset);
            var encoded:String = _mimeEncoder.encode(arr);
            return "=?" + charset.toUpperCase() + "?" + _mimeEncoder.initial + "?" + encoded + "?=";
        }
    }
}

