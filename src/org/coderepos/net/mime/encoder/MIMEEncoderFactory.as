package org.coderepos.net.mime.encoder
{
    public class MIMEEncoderFactory
    {
        private var _b64encoder:Base64Encoder;
        private var _quotedPrintableEncoder:QuotedPrintableEncoder;
        private var _byteEncoder:ByteEncoder;

        public function MIMEEncoderFactory(b64encoder:Base64Encoder,
            quotedPrintableEncoder:QuotedPrintableEncoder,
            byteEncoder:ByteEncoder=null)
        {
            _b64encoder             = b64encoder;
            _quotedPrintableEncoder = quotedPrintableEncoder;
            _byteEncoder            = (byteEncoder != null) ? byteEncoder : new ByteEncoder();
        }

        public function getByTransferEncoding(encoding:String):IMIMEEncoder
        {
            if (encoding == "base64")
                return _b64encoder;
            else if (encoding == "quoted-printable")
                return _quotedPrintableEncoder;
            return _byteEncoder;
        }

        public function getByName(name:String):IMIMEEncoder
        {
            if (name == "base64")
                return _b64encoder;
            else if (name == "quoted-printable")
                return _quotedPrintableEncoder;
            return null;
        }

        public function getByInitial(initial:String):IMIMEEncoder
        {
            if (initial == 'B')
                return _b64encoder;
            else if (initial == 'Q')
                return _quotedPrintableEncoder;
            return null;
        }
    }
}

