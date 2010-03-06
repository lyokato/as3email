package org.coderepos.net.mime
{
    import flash.utils.ByteArray;

    import com.adobe.utils.StringUtil;
    import com.adobe.utils.DateUtil;

    import org.coderepos.net.mime.exceptions.MIMEFormatError;
    import org.coderepos.net.mime.utils.HeaderValueDecoder;
    import org.coderepos.net.mime.utils.RFC2231Decoder;
    import org.coderepos.net.mime.charset.IMIMECharsetEncoder;
    import org.coderepos.net.mime.charset.MIMEDefaultCharsetEncoder;
    import org.coderepos.net.mime.encoder.IMIMEEncoder;
    import org.coderepos.net.mime.encoder.QuotedPrintableEncoder;
    import org.coderepos.net.mime.encoder.Base64Encoder;
    import org.coderepos.net.mime.encoder.MIMEEncoderFactory;
    import org.coderepos.net.mime.mediatype.MediaTypeParser;
    import org.coderepos.net.mime.mediatype.MediaType;

    public class MIMEParser
    {
        private var _encoderFactory:MIMEEncoderFactory;
        private var _headerValueDecoder:HeaderValueDecoder;
        private var _mediaTypeParser:MediaTypeParser;
        private var _charsetEncoder:IMIMECharsetEncoder;

        public function MIMEParser()
        {
            var b64:Base64Encoder         = new Base64Encoder();
            var qp:QuotedPrintableEncoder = new QuotedPrintableEncoder();
            _charsetEncoder               = new MIMEDefaultCharsetEncoder();
            var rfc2231:RFC2231Decoder    = new RFC2231Decoder(_charsetEncoder);
            _encoderFactory               = new MIMEEncoderFactory(b64, qp);
            _headerValueDecoder           = new HeaderValueDecoder(_encoderFactory, _charsetEncoder);
            _mediaTypeParser              = new MediaTypeParser(_headerValueDecoder, rfc2231);
        }

        private function decodeHeaderValue(value:String):String
        {
            return _headerValueDecoder.decodeLine(value);
        }

        private function parseMediaType(value:String):MediaType
        {
            return _mediaTypeParser.parse(value);
        }

        private function splitAddressFieldValue(message:MIMEMessage,
            value:String, recipeintType:String):void
        {
            // XXX: how to handle group list?
            // value.split(/;/);
            var addresses:Array = value.split(/\,/);
            var len:int = addresses.length;
            for (var i:int = 0; i < len; i++) {
                var address:MIMEMailAddress =
                    parseAddressFieldValue(StringUtil.trim(addresses[i]));
                switch (recipeintType) {
                    case RecipientType.TO:
                        message.addTo(address);
                        break;
                    case RecipientType.CC:
                        message.addCc(address);
                        break;
                    case RecipientType.BCC:
                        message.addBcc(address);
                        break;
                }
            }
        }

        private function parseAddressFieldValue(src:String):MIMEMailAddress
        {
            var address:String;
            var nick:String = null;

            var match:Array = src.match(/^\s*(.*[^\s]+)?\s*\<([^>]+)\>\s*$/);
            if (match != null) {
                if (match[1] != null)
                    nick = decodeHeaderValue(match[1]);
                address = match[2];
            } else {
                // XXX: TODO mail address format validation
                address = src;
            }
            return new MIMEMailAddress(address, nick);
        }

        public function parse(srcBytes:ByteArray):MIMEMessage
        {
            srcBytes.position = 0;
            var src:String = srcBytes.readUTFBytes(srcBytes.length);
            var separator:int = src.indexOf("\r\n\r\n");
            if (separator == -1) {
                throw new MIMEFormatError("Invalid MIME format: " + src);
            }
            var header:Object = parseHeader(src.substring(0, separator));
            var body:String = src.substring(separator + 4);

            var message:MIMEMessage = new MIMEMessage();

            if ("to" in header)
                splitAddressFieldValue(message, header['to'], RecipientType.TO);

            if ("cc" in header)
                splitAddressFieldValue(message, header['cc'], RecipientType.CC);

            if ("bcc" in header)
                splitAddressFieldValue(message, header['bcc'], RecipientType.BCC);

            delete header["to"];
            delete header["cc"];
            delete header["bcc"];

            if ("from" in header) {
                message.from = parseAddressFieldValue(header['from']);
            } else if ("apparently-from" in header) {
                message.from = parseAddressFieldValue(header["apparently-from"]);
            } else {
                throw new MIMEFormatError("from not found: " + src);
            }
            delete header["from"];
            delete header["apparently-from"];

            if ("sender" in header) {
                message.sender = parseAddressFieldValue(header['sender']);
                delete header["sender"];
            }

            if ("reply-to" in header) {
                message.replyTo = MIMEMailAddress.parse(header['reply-to']);
                delete header["reply-to"];
            }

            if ("in-reply-to" in header) {
                message.inReplyTo = MIMEUtil.parseMessageID(header['in-reply-to']); // MessageID
                delete header['in-reply-to'];
            }

            if ("message-id" in header) {
                message.messageID = MIMEUtil.parseMessageID(header['message-id']); // MessageID
                delete header['message-id'];
            }

            if ("references" in header) {
                message.references = MIMEUtil.parseReferences(header["references"]);
                delete header["references"];
            }

            if ("received" in header) {
                message.received = header['received'];
                delete header["received"];
            }

            if ("return-path" in header) {
                message.returnPath = header['return-path'];
                delete header["return-path"];
            }

            // subject
            message.subject = ("subject" in header) ? header["subject"] : "";

            // Date
            try {
                if ("date" in header)
                    message.date = DateUtil.parseRFC822(header["date"]);
                else
                    message.date = new Date();
            } catch (e:Error) {
                // FIXME
                message.date = new Date();
                //throw new MIMEFormatError("invalid date format: " + header["date"]);
            }
            delete header['date'];

            // User-Agent
            if ("x-mailer" in header) {
                message.userAgent = header["x-mailer"];
            } else if ("user-agent" in header) {
                message.userAgent = header["user-agent"];
            }
            delete header['x-mailer'];
            delete header['user-agent'];

            // Priority
            if ("prority" in header) {
                message.priority = header['priority'];
            } else if ("x-priority" in header) {
                message.priority =
                    MIMEPriority.fromXPriority(header['x-priority']);
            } else if ("x-msmail-priority" in header) {
                message.priority =
                    MIMEPriority.fromMSMailPriority(header['x-msmail-priority']);
            }
            delete header['priority'];
            delete header['x-priority'];
            delete header['x-msmail-priority'];

            if ("status" in header) {
                message.status = header['status'];
                delete header['status'];
            }

            if ("x-uid" in header) {
                message.uid = header['x-uid'];
                delete header['x-uid'];
            }

            if ("content-id" in header) {
                message.contentID = header['content-id'];
                delete header['content-id'];
            }

            // Content-Type
            var contentTypeSrc:String = ("content-type" in header)
                ? header["content-type"] : "text/plain; charset='US-ASCII'";
            var contentType:MediaType = parseMediaType(contentTypeSrc);
            delete header['content-type'];

            // Content-Transfer-Encoding
            var contentTransferEncoding:String = ("content-transfer-encoding" in header)
                ? header['content-transfer-encoding'] : ContentTransferEncodingType.SEVENBIT;
            delete header['content-transfer-encoding'];

            for (var prop:String in header)
                message.setUnsupportedHeader(prop, header[prop]);

            if (contentType.type.match(/^multipart\//i) != null) {

                var boundary:String = contentType.getParam("boundary");
                if (boundary == null)
                    throw new MIMEFormatError("Multipart message, but no boundary found: " + src);
                var delimBoundary:String = "--" + boundary;
                var endBoundary:String = delimBoundary + "--";
                delimBoundary += "\r\n";

                var firstPartPos:int = body.indexOf(delimBoundary);
                if (firstPartPos == -1)
                    throw new MIMEFormatError("Boundary '" + delimBoundary + "' not found:" + src);
                firstPartPos += delimBoundary.length;
                var endPos:int = body.indexOf(endBoundary);
                if (endPos == -1)
                    throw new MIMEFormatError("Ending boundary '" + endBoundary + "' not found");

                body = body.substring(firstPartPos, endPos);

                var part:MIMEPart;
                var firstPart:Boolean = true;
                while (true) {
                    var nextPartEndPos:int = body.indexOf(delimBoundary);
                    if (nextPartEndPos == -1) {
                        // this is the last part
                        try {
                            part = parsePart(body);
                        } catch (e:*) {
                            // continue
                            throw e;
                        }
                        if (firstPart) {
                            firstPart = false;
                            if (part.isText) {
                                message.setText(part.getText(), part.charset);
                            } else {
                                message.setBinary(part.contentType, part.getBinary());
                            }
                        } else {
                            message.addPart(part);
                        }
                        break;
                    }
                    var partSrc:String = body.substring(0, nextPartEndPos);
                    body = body.substring(nextPartEndPos + delimBoundary.length);
                    try {
                        part = parsePart(partSrc);
                    } catch (e:*) {
                        // continue
                        throw e;
                    }
                    if (firstPart) {
                        firstPart = false;
                        if (part.isText) {
                            message.setText(part.getText(), part.charset);
                        } else {
                            message.setBinary(part.contentType, part.getBinary());
                        }
                    } else {
                        message.addPart(part);
                    }
                }

            } else {

                var encoder:IMIMEEncoder =
                    _encoderFactory.getByTransferEncoding(contentTransferEncoding);
                var bodyBytes:ByteArray = encoder.decode(body);

                if (contentType.type.match(/^text\//i) != null) {

                    var charset:String = contentType.getParam("charset");
                    if (charset == null)
                        charset = "US-ASCII";
                    var text:String = _charsetEncoder.decode(bodyBytes, charset);
                    message.setText(text, 'UTF-8');

                } else {

                    message.setBinary(contentType.valueOf(), bodyBytes);

                }

            }

            return message;
        }

        public function parsePart(src:String):MIMEPart
        {
            var separator:int = src.indexOf("\r\n\r\n");
            if (separator == -1) {
                throw new MIMEFormatError("Invalid MIME format: " + src);
            }
            var header:Object = parseHeader(src.substring(0, separator));
            var body:String = src.substring(separator + 4);

            var part:MIMEPart = new MIMEPart();

            var contentType:MediaType;
            if ("content-type" in header) {
                var contentTypeSrc:String = header["content-type"];
                contentType = parseMediaType(contentTypeSrc);
            } else {
                contentType = parseMediaType("text/plain; charset='US-ASCII'");
            }

            var contentTransferEncoding:String;
            if ("content-transfer-encoding" in header) {
                contentTransferEncoding = header["content-transfer-encoding"];
            } else {
                contentTransferEncoding = "7bit";
            }

            if ("content-description" in header) {
                part.contentDescription = header["content-description"];
            }
            if ("content-disposition" in header) {
                var dispSrc:MediaType = parseMediaType(header['content-disposition']);
                var disposition:ContentDisposition = new ContentDisposition(dispSrc.type);
                if (dispSrc.hasParam("filename"))
                    disposition.filename = dispSrc.getParam("filename");
                if (dispSrc.hasParam("creation-date")) {
                    try {
                        disposition.creationDate =
                            DateUtil.parseRFC822(dispSrc.getParam("creation-date"));
                    } catch (e:Error) { }
                }
                if (dispSrc.hasParam("modification-date")) {
                    try {
                        disposition.modificationDate =
                            DateUtil.parseRFC822(dispSrc.getParam("modification-date"));
                    } catch (e:Error) { }
                }
                if (dispSrc.hasParam("read-date")) {
                    try {
                        disposition.readDate =
                            DateUtil.parseRFC822(dispSrc.getParam("read-date"));
                    } catch (e:Error) { }
                }
                if (dispSrc.hasParam("size"))
                    disposition.size = uint(dispSrc.getParam("size"));

                part.contentDisposition = disposition;
            }

            if (contentType.type.match(/^multipart\//i) != null) {

                var boundary:String = contentType.getParam("boundary");
                if (boundary == null)
                    throw new MIMEFormatError("Multipart message, but no boundary found: " + src);
                var delimBoundary:String = "--" + boundary;
                var endBoundary:String = delimBoundary + "--";
                delimBoundary += "\r\n";

                var firstPartPos:int = body.indexOf(delimBoundary);
                if (firstPartPos == -1)
                    throw new MIMEFormatError("Boundary '" + delimBoundary + "' not found");
                firstPartPos += delimBoundary.length;
                var endPos:int = body.indexOf(endBoundary);
                if (endPos == -1)
                    throw new MIMEFormatError("Ending boundary '" + endBoundary + "' not found");

                body = body.substring(firstPartPos, endPos);

                var p:MIMEPart;
                var firstPart:Boolean = true;
                while (true) {
                    var nextPartEndPos:int = body.indexOf(delimBoundary);
                    if (nextPartEndPos == -1) {
                        try {
                            p = parsePart(body);
                        } catch (e:*) {
                            // continue
                            throw e;
                        }
                        if (firstPart) {
                            if (p.isText) {
                                part.setText(p.getText(), p.charset);
                            } else {
                                part.setBinary(p.contentType, p.getBinary());
                            }
                            firstPart = false;
                        } else {
                            part.addPart(p);
                        }
                        break;
                    }
                    var partSrc:String = body.substring(0, nextPartEndPos);
                    body = body.substring(nextPartEndPos + delimBoundary.length);
                    try {
                        p = parsePart(partSrc);
                    } catch (e:*) {
                        // continue
                        throw e;
                    }
                    if (firstPart) {
                        if (p.isText) {
                            part.setText(p.getText(), p.charset);
                        } else {
                            part.setBinary(p.contentType, p.getBinary());
                        }
                        firstPart = false;
                    } else {
                        part.addPart(p);
                    }
                }

            } else {

                var encoder:IMIMEEncoder =
                    _encoderFactory.getByTransferEncoding(contentTransferEncoding);
                var bodyBytes:ByteArray = encoder.decode(body);

                if (contentType.type.match(/^text\//i) != null) {
                    var charset:String = contentType.getParam("charset");
                    if (charset == null)
                        charset = "US-ASCII";
                    var text:String = _charsetEncoder.decode(bodyBytes, charset);
                    part.setText(text, 'UTF-8');
                } else {
                    part.setBinary(contentType.valueOf(), bodyBytes);
                }


            }
            return part;
        }

        public function parseHeader(src:String):Object
        {
            var lines:Array = src.split(/\r\n/);
            var len:int = lines.length;
            var header:Object = {};

            var key:String;
            var value:String;

            var line:String;
            var colon:int;
            var trailing:String;

            while (true) {
                var lineBreak:int = src.indexOf("\r\n");
                // XXX: dirty, fix later
                if (lineBreak == -1) {
                    line = src;
                    if (line.match(/^[\s\t]/) == null) {
                        colon = line.indexOf(":");
                        if (colon == -1)
                            throw new MIMEFormatError("Invalid MIME header: " + src);
                        if (value != null)
                            header[key.toLowerCase()] = value;
                        key = StringUtil.rtrim(line.substring(0, colon));
                        value = decodeHeaderValue(StringUtil.ltrim(line.substring(colon + 1)));
                    } else {
                        trailing = StringUtil.trim(line);
                        if (trailing.length > 0) {
                            if (value == null)
                                value = decodeHeaderValue(trailing);
                            else
                                value += decodeHeaderValue(trailing);
                        }
                    }
                    header[key.toLowerCase()] = value;
                    break;
                }
                line = src.substring(0, lineBreak);
                src = src.substring(lineBreak + 2);

                if (line.match(/^[\s\t]/) == null) {
                    colon = line.indexOf(":");
                    if (colon == -1)
                        throw new MIMEFormatError("Invalid MIME header: " + src);
                    if (value != null)
                        header[key.toLowerCase()] = value;
                    key = StringUtil.rtrim(line.substring(0, colon));
                    value = decodeHeaderValue(StringUtil.ltrim(line.substring(colon + 1)));
                } else {
                    trailing = StringUtil.trim(line);
                    if (trailing.length > 0) {
                        if (value == null)
                            value = decodeHeaderValue(trailing);
                        else
                            value += decodeHeaderValue(trailing);
                    }
                }
            }
            return header;
        }
    }
}

