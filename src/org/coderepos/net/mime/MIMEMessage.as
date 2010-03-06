package org.coderepos.net.mime
{
    import flash.utils.ByteArray;

    public class MIMEMessage
    {
        private var _to:Array;  // Vector.<MIMEMailAddress>
        private var _cc:Array;  // Vector.<MIMEMailAddress>
        private var _bcc:Array; // Vector.<MIMEMailAddress>

        private var _from:MIMEMailAddress;
        private var _sender:MIMEMailAddress;
        private var _replyTo:MIMEMailAddress;
        private var _subject:String;

        private var _messageID:String;  // MessageID
        private var _inReplyTo:String;  // MessageID
        private var _references:Array; // Vector.<MessageID>

        private var _date:Date;        // Date
        private var _priority:String;  // Priority | X-Priority | X-MSMail-Priority
        private var _userAgent:String; // User-Agent | X-Mailer
        private var _status:String;    // Status
        private var _uid:String;       // X-UID

        private var _contentType:String;
        private var _contentID:String;
        private var _returnPath:String;
        private var _received:String;

        private var _parts:Array; // Vector.<MIMEPart>
        private var _charset:String;
        private var _textBody:String;
        private var _binaryBody:ByteArray;
        private var _multipartType:String;

        private var _unsupportedHeader:Object;

        public function MIMEMessage()
        {
            _contentType       = "text/plain charset='US-ASCII'";
            _textBody          = null;
            _charset           = "US-ASCII";
            _userAgent         = "as3messaging";
            _multipartType     = "mixied";
            _priority          = MIMEPriority.NORMAL;
            _unsupportedHeader = {};

            _to         = [];
            _cc         = [];
            _bcc        = [];
            _references = [];
            _parts      = [];
        }

        public function get contentType():String
        {
            return _contentType;
        }

        public function get charset():String
        {
            return _charset;
        }

        public function addTo(address:MIMEMailAddress):void
        {
            _to.push(address);
        }

        public function get to():Array
        {
            return _to;
        }

        public function addCc(address:MIMEMailAddress):void
        {
            _cc.push(address);
        }

        public function get cc():Array
        {
            return _cc;
        }

        public function addBcc(address:MIMEMailAddress):void
        {
            _bcc.push(address);
        }

        public function get bcc():Array
        {
            return _bcc;
        }

        public function get replyTo():MIMEMailAddress
        {
            return _replyTo;
        }

        public function set replyTo(address:MIMEMailAddress):void
        {
            _replyTo = address;
        }

        public function get date():Date
        {
            if (_date == null)
                _date = new Date();
            return _date;
        }

        public function set date(d:Date):void
        {
            _date = d;
        }

        public function get messageID():String
        {
            if (_messageID == null)
                _messageID = MIMEUtil.genMessageID();
            return _messageID;
        }

        public function set messageID(mid:String):void
        {
            _messageID = mid;
        }

        public function get inReplyTo():String
        {
            return _inReplyTo;
        }

        public function set inReplyTo(id:String):void
        {
            _inReplyTo = id;
        }

        public function addReference(msgID:String):void
        {
            _references.push(msgID);
        }

        public function get references():Array
        {
            return _references;
        }

        public function set references(refs:Array):void
        {
            _references = refs;
        }

        public function get priority():String
        {
            return _priority;
        }

        public function set priority(level:String):void
        {
            // MIMEPriority.NORMAL/URGENT/NON_URGENT
            _priority = level;
        }

        public function get status():String
        {
            return _status;
        }

        public function set status(s:String):void
        {
            _status = s;
        }

        public function get userAgent():String
        {
            return _userAgent;
        }

        public function set userAgent(agentName:String):void
        {
            _userAgent = agentName;
        }

        public function get uid():String
        {
            return _uid;
        }

        public function set uid(id:String):void
        {
            _uid = id;
        }


        public function get contentID():String
        {
            return _contentID;
        }

        public function set contentID(id:String):void
        {
            _contentID = id;
        }

        public function get returnPath():String
        {
            return _returnPath;
        }

        public function set returnPath(path:String):void
        {
            _returnPath = path;
        }

        public function get received():String
        {
            return _received;
        }

        public function set received(received:String):void
        {
            _received = received;
        }

        public function get subject():String
        {
            return _subject;
        }

        public function set subject(subject:String):void
        {
            _subject = subject;
        }

        public function get multipartType():String
        {
            return _multipartType;
        }

        public function set multipartType(type:String):void
        {
            _multipartType = type;
        }

        public function get isMultipart():Boolean
        {
            return (_parts.length > 0);
        }

        public function get isText():Boolean
        {
            return (_contentType.match(/^text\//i) != null);
        }

        public function setText(text:String, charset:String="UTF-8"):void
        {
            _contentType = "text/plain; charset=" + charset + "";
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

        /*
        public function addMessage(msg:MIMEMessage):void
        {
            var part:MIMEPart = new MIMEPart();
            part.contentType = "message/rfc822";
            part.contentTransferEncoding = "7bit";
            part.contentDisposition = "inline";
            part.setBody(msg.valueOf());
            _parts.push(part);
        }
        */

        public function hasRecipient():Boolean
        {
            return (getAllRecipients().length > 0);
        }

        public function get from():MIMEMailAddress
        {
            return _from;
        }

        public function set from(address:MIMEMailAddress):void
        {
            _from = address;
        }

        public function get sender():MIMEMailAddress
        {
            return _sender;
        }

        public function set sender(address:MIMEMailAddress):void
        {
            _sender = address;
        }

        public function addPart(part:MIMEPart):void
        {
            _parts.push(part);
        }

        public function get parts():Array
        {
            return _parts;
        }

        public function getUnsupportedHeaderValue(key:String):String
        {
            return (key in _unsupportedHeader) ? _unsupportedHeader[key] : null;
        }

        public function setUnsupportedHeader(key:String, value:String):void
        {
            _unsupportedHeader[key] = value;
        }

        public function getAllRecipients():Array
        {
            var addresses:Array = [];
            if (_to.length > 0)
                addresses = addresses.concat(_to);
            if (_cc.length > 0)
                addresses = addresses.concat(_cc);
            if (_bcc.length > 0)
                addresses = addresses.concat(_bcc);
            return addresses;
        }

    }
}

