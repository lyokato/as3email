package org.coderepos.net.mime
{
    import flash.utils.ByteArray;

    public class MIMEPart
    {
        private var _contentType:String;
        private var _contentDisposition:ContentDisposition;
        private var _contentDescription:String;
        private var _parts:Array; // Vector.<MIMEPart>

        private var _charset:String;
        private var _textBody:String;
        private var _binaryBody:ByteArray;
        private var _multipartType:String;

        public function MIMEPart()
        {
            _contentType        = "text/plain; charset='US-ASCII'";
            _charset            = 'US-ASCII';
            _textBody           = "";
            _contentDisposition = null;
            _contentDescription = "";
            _multipartType      = "mixed";
            _parts              = [];
        }

        public function get contentType():String
        {
            return _contentType;
        }

        public function get charset():String
        {
            return _charset;
        }

        public function set multipartType(type:String):void
        {
            _multipartType = type;
        }

        public function get multipartType():String
        {
            return _multipartType;
        }

        public function get isText():Boolean
        {
            return (_contentType.match(/^text\//i) != null);
        }

        public function get isMultipart():Boolean
        {
            return (_parts.length > 0);
        }

        public function setText(text:String, charset:String='US-ASCII'):void
        {
            _contentType = "text/plain; charset='" + charset + "'";
            _charset     = charset;
            _textBody    = text;
            _binaryBody  = null;
        }

        public function getText():String
        {
            return (isText) ? _textBody : null;
        }

        public function setBinary(type:String, bytes:ByteArray):void
        {
            if (type.match(/^text\//i) != null)
                throw new ArgumentError("call setText instread of setBinary");

            _contentType = type;
            _binaryBody  = bytes;
            _textBody    = null;
        }

        public function getBinary():ByteArray
        {
            return (isText) ? null : _binaryBody;
        }

        public function get contentDisposition():ContentDisposition
        {
            return _contentDisposition;
        }

        public function set contentDisposition(disp:ContentDisposition):void
        {
            _contentDisposition = disp;
        }

        public function get contentDescription():String
        {
            return _contentDescription;
        }

        public function set contentDescription(desc:String):void
        {
            _contentDescription = desc;
        }

        public function addPart(part:MIMEPart):void
        {
            _parts.push(part);
        }

        public function get parts():Array
        {
            return _parts;
        }

    }
}

