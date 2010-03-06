package org.coderepos.net.mime
{
    import flash.utils.ByteArray;

    import com.adobe.utils.DateUtil;

    import org.coderepos.net.mime.encoder.Base64Encoder;
    import org.coderepos.net.mime.mediatype.MediaType;
    import org.coderepos.net.mime.charset.IMIMECharsetEncoder;
    import org.coderepos.net.mime.charset.MIMEDefaultCharsetEncoder;
    import org.coderepos.net.mime.utils.HeaderValueEncoder;

    public class MIMEFormatter
    {
        private var _headerValueEncoder:HeaderValueEncoder;
        private var _headerCharset:String;
        private var _b64Encoder:Base64Encoder;
        private var _charsetEncoder:IMIMECharsetEncoder;

        public function MIMEFormatter()
        {
            _headerCharset      = "UTF-8";
            _b64Encoder         = new Base64Encoder();
            _charsetEncoder     = new MIMEDefaultCharsetEncoder();
            _headerValueEncoder = new HeaderValueEncoder(_charsetEncoder, _b64Encoder);
        }

        public function formatToString(message:MIMEMessage):String
        {
            var bytes:ByteArray = formatToBytes(message);
            bytes.position = 0;
            return bytes.readUTFBytes(bytes.length);
        }

        public function buildSubjectField(subject:String):String
        {
            var subjectField:Array = [];
            if (subject.match(/^[\x01-\x7f]+$/) == null) {
                // fold by 24
                // TODO: more better calculation
                while (true) {
                    if (subject.length > 24) {
                        subjectField.push(
                            _headerValueEncoder.encode(
                                subject.substring(0, 24), _headerCharset));
                        subject = subject.substring(24);
                    } else {
                        subjectField.push(
                            _headerValueEncoder.encode(
                                subject, _headerCharset));
                        break;
                    }
                }
            } else {
                // fold by 72?
                while (true) {
                    if (subject.length > 72) {
                        subjectField.push(subject.substring(0, 72));
                        subject = subject.substring(72);
                    } else {
                        subjectField.push(subject);
                        break;
                    }
                }
            }
            return subjectField.join("\r\n ");
        }

        public function formatToBytes(message:MIMEMessage):ByteArray
        {
            if (!message.hasRecipient())
                throw new Error("Threre is no address.");

            if (message.from == null)
                throw new Error("From not found.");

            if (!(message.subject != null && message.subject.length > 0))
                throw new Error("subject not found.");

            var bytes:ByteArray = new ByteArray();

            bytes.writeUTFBytes("Date: " + DateUtil.toRFC822(message.date) + "\r\n");
            bytes.writeUTFBytes("From: " + buildAddressFieldValue([message.from]) + "\r\n");

            bytes.writeUTFBytes("To: " + buildAddressFieldValue(message.to) + "\r\n");
            if (message.cc.length > 0)
                bytes.writeUTFBytes("Cc: " + buildAddressFieldValue(message.cc) + "\r\n");
            if (message.bcc.length > 0)
                bytes.writeUTFBytes("Bcc: " + buildAddressFieldValue(message.bcc) + "\r\n");


            if (message.sender != null)
                bytes.writeUTFBytes("Sender: " + buildAddressFieldValue([message.sender]) + "\r\n");

            if (message.replyTo != null)
                bytes.writeUTFBytes("Reply-To: " + buildAddressFieldValue([message.replyTo]) + "\r\n");

            var subject:String = buildSubjectField(message.subject);
            bytes.writeUTFBytes("Subject: " + subject + "\r\n");

            bytes.writeUTFBytes("Message-ID: <" + message.messageID + ">\r\n");
            if (message.inReplyTo != null)
                bytes.writeUTFBytes("In-Reply-To: <" + message.inReplyTo + ">\r\n");

            if (message.references != null) {
                var references:String = "";
                for (var i:int = 0; i < message.references.length; i++) {
                    if (i != 0)
                        references += "\r\n ";
                    references += "<" + message.references[i] + ">";
                }
                bytes.writeUTFBytes("References: " + references + "\r\n");
            }

            bytes.writeUTFBytes("MIME-Version: 1.0\r\n");

            if (message.userAgent != null && message.userAgent.length > 0)
                bytes.writeUTFBytes("X-Mailer: " + message.userAgent + "\r\n");

            if (message.priority != null) {
                bytes.writeUTFBytes("Priority: " + message.priority + "\r\n");
                bytes.writeUTFBytes("X-Priority: " + MIMEPriority.getXPriority(message.priority) + "\r\n");
                bytes.writeUTFBytes("X-MSMail-Priority: " + MIMEPriority.getMSMailPriority(message.priority) + "\r\n");
            }

            if (message.status != null)
                bytes.writeUTFBytes("Status: " + message.status + "\r\n");

            if (message.parts.length > 0) {
                // multipart
                var multipartType:String = "multipart/";
                multipartType += message.multipartType;
                bytes.writeUTFBytes("Content-Type: " + multipartType + "\r\n");
                bytes.writeUTFBytes("Content-Transfer-Encoding: 7bit\r\n");
                bytes.writeUTFBytes("\r\n");

                var boundary:String = MIMEUtil.genBoundary();
                // write first part
                bytes.writeUTFBytes("--" + boundary + "\r\n");
                writeContent(bytes, message);

                for (i = 0; i < message.parts.length; i++) {
                    bytes.writeUTFBytes("--" + boundary + "\r\n");
                    writePart(bytes, message.parts[i]);
                }
                bytes.writeUTFBytes("--" + boundary + "--\r\n");

            } else {

                writeContent(bytes, message);

            }
            bytes.writeUTFBytes("\r\n.\r\n");
            bytes.position = 0;
            return bytes;

        }

        private function writeContent(bytes:ByteArray, message:MIMEMessage):void
        {
            bytes.writeUTFBytes("Content-Type: " + message.contentType + "\r\n");

            if (message.isText) {

                var textBody:String = message.getText();
                if (textBody == null)
                    textBody = "";
                //if (_charset == "US-ASCII") { 
                if (textBody.match(/^[\x01-\x7f]+$/) != null) {

                    bytes.writeUTFBytes("Content-Transfer-Encoding: 7bit\r\n");
                    bytes.writeUTFBytes("\r\n");
                    bytes.writeUTFBytes(textBody.replace(/\r\n\.\r\n/g, "\r\n..\r\n"));

                } else {

                    var data:String = _b64Encoder.encode(_charsetEncoder.encode(textBody, message.charset));
                    bytes.writeUTFBytes("Content-Transfer-Encoding: base64\r\n");
                    bytes.writeUTFBytes("\r\n");
                    bytes.writeUTFBytes(data);
                }

            } else {

                var binData:String = _b64Encoder.encode(message.getBinary());
                bytes.writeUTFBytes("Content-Transfer-Encoding: base64\r\n");
                bytes.writeUTFBytes("\r\n");
                bytes.writeUTFBytes(binData);
            }

        }

        private function buildAddressFieldValue(addresses:Array):String
        {
            var len:int = addresses.length;
            var results:Array = [];
            for (var i:uint = 0; i < len; i++) {
                var nick:String    = addresses[i].nickname;
                var address:String = addresses[i].address;
                if (nick != null) {
                    results.push(_headerValueEncoder.encodeLine(nick, _headerCharset)
                        + "\r\n " + "<" + address + ">");
                } else {
                    results.push(address);
                }

            }
            return results.join(",\r\n ");
        }

        private function writePart(bytes:ByteArray, part:MIMEPart):void
        {
            if (part.parts.length > 0) {
                // multipart
                var multipartType:String = "multipart/";
                multipartType += part.multipartType;
                bytes.writeUTFBytes("Content-Type: " + multipartType + "\r\n");
                bytes.writeUTFBytes("Content-Transfer-Encoding: 7bit\r\n");
                bytes.writeUTFBytes("\r\n");
                // write first part
                var boundary:String = MIMEUtil.genBoundary();
                bytes.writeUTFBytes("--" + boundary + "\r\n");
                writePartContent(bytes, part);
                for (var i:int = 0; i < part.parts.length; i++) {
                    bytes.writeUTFBytes("--" + boundary + "\r\n");
                    writePart(bytes, part.parts[i]);
                }
                bytes.writeUTFBytes("--" + boundary + "--\r\n");
            } else {
                writePartContent(bytes, part);
            }
        }

        private function writePartContent(bytes:ByteArray, part:MIMEPart):void
        {
            bytes.writeUTFBytes("Content-Type: " + part.contentType + "\r\n");

            if (part.contentDescription != null)
                bytes.writeUTFBytes("Content-Description: " + part.contentDescription + "\r\n");

            if (part.contentDisposition != null) {

                var disp:ContentDisposition = part.contentDisposition;
                var dispValue:MediaType = new MediaType(disp.type);

                if (disp.filename != null && disp.filename.length > 0) {
                    if (disp.filename.match(/^[\x01-\x7f]+$/) != null) {
                        // TODO: fold if filename is too long
                        dispValue.addParam('filename', disp.filename);
                    } else {
                        // multibyte
                        // TODO: later
                    }
                }
                if (disp.creationDate != null)
                    dispValue.addParam('creation-date',
                        DateUtil.toRFC822(disp.creationDate));
                if (disp.modificationDate != null)
                    dispValue.addParam('modification-date',
                        DateUtil.toRFC822(disp.modificationDate));
                if (disp.readDate != null)
                    dispValue.addParam('read-date',
                        DateUtil.toRFC822(disp.readDate));
                if (disp.size != 0)
                    dispValue.addParam('size', String(disp.size));
                bytes.writeUTFBytes("Content-Disposition: " + dispValue.valueOf() + "\r\n");
            }

            if (part.isText) {

                //if (_charset == "US-ASCII") { 
                var textBody:String = part.getText();
                if (textBody == null)
                    textBody = "";
                if (textBody.match(/^[\x01-\x7f]+$/) != null) {

                    bytes.writeUTFBytes("Content-Transfer-Encoding: 7bit\r\n");
                    bytes.writeUTFBytes("\r\n");
                    bytes.writeUTFBytes(textBody.replace(/\r\n\.\r\n/g, "\r\n..\r\n"));

                } else {

                    var data:String = _b64Encoder.encode(_charsetEncoder.encode(textBody, part.charset));
                    bytes.writeUTFBytes("Content-Transfer-Encoding: base64\r\n");
                    bytes.writeUTFBytes("\r\n");
                    bytes.writeUTFBytes(data);
                }

            } else {

                var binData:String = _b64Encoder.encode(part.getBinary());
                bytes.writeUTFBytes("Content-Transfer-Encoding: base64\r\n");
                bytes.writeUTFBytes("\r\n");
                bytes.writeUTFBytes(binData);
            }
        }
    }
}

