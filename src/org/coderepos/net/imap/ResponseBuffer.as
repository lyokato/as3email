package org.coderepos.net.imap
{
    import flash.utils.ByteArray;
    import flash.events.EventDispatcher;
    import flash.events.ErrorEvent;

    import org.coderepos.net.imap.parser.IResponseParser;
    import org.coderepos.net.imap.events.IMAPResponseEvent;
    import org.coderepos.net.imap.events.IMAPErrorEvent;

    public class ResponseBuffer extends EventDispatcher
    {
        private static const CRLF:String = "\r\n";

        private var _bytes:ByteArray;
        private var _parser:IResponseParser;

        private var _isProcessingLiteral:Boolean;
        private var _literalLength:uint;
        private var _literalBytes:ByteArray;
        private var _processingLine:String;

        public function ResponseBuffer(parser:IResponseParser)
        {
            _bytes = new ByteArray();
            _parser = parser;

            _isProcessingLiteral = false;
            _literalLength       = 0;
        }

        public function writeBytes(b:ByteArray):void
        {
            if (_isProcessingLiteral) {
                _literalBytes.writeBytes(b, 0, b.length);
                processLiteral();
            } else {
                process(b);
            }
        }

        private function processLiteral():void
        {

            if (_literalBytes.length < _literalLength)
                return;

            _literalBytes.position = 0;
            _processingLine += _literalBytes.readUTFBytes(_literalLength);
            parseLine(_processingLine);

            _bytes = new ByteArray();
            if (_literalBytes.length - _literalLength > 0)
                _literalBytes.readBytes(_bytes);

            _processingLine      = null;
            _literalLength       = 0;
            _literalBytes        = null;
            _isProcessingLiteral = false;
        }

        private function process(b:ByteArray):void
        {
            _bytes.writeBytes(b, 0, b.length);
            var s:String = IMAPUtil.bytesToString(_bytes);
            while (true) {
                var endOfLine:int = s.indexOf(CRLF);
                // finish loop if CRLF is not found
                if (endOfLine == -1)
                    break;
                // if found, get line
                var line:String = s.substring(0, endOfLine + CRLF.length);
                s = s.substring(endOfLine + CRLF.length);
                var literalMatch:Array = line.match(/\{(\d+)\}\r\n$/);
                if (literalMatch == null) {
                // if response doesn't include literal
                    parseLine(line);
                } else {
                // if response includes literal
                    _literalLength       = uint(literalMatch[1]);
                    _literalBytes        = IMAPUtil.stringToBytes(s);
                    _processingLine      = line;
                    _isProcessingLiteral = true;

                    processLiteral();
                    s = IMAPUtil.bytesToString(_bytes);
                }
            }
            _bytes = IMAPUtil.stringToBytes(s);
            _bytes.position = _bytes.length;
        }

        private function parseLine(line:String):void
        {
            var parsed:Boolean = false;
            var res:*;
            try {
                res = _parser.parse(line);
                parsed = true;
            } catch (e:Error) {
                dispatchEvent(new IMAPErrorEvent(
                    IMAPErrorEvent.PARSE_ERROR, e.toString()));
            }
            if (parsed) {
                dispatchEvent(new IMAPResponseEvent(
                    IMAPResponseEvent.RECEIVE, res));
            }
        }

    }
}

