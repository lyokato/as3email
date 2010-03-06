package org.coderepos.net.smtp
{
    import flash.utils.ByteArray;
    import org.coderepos.net.smtp.exceptions.SMTPResponseFormatError;

    public class SMTPResponseBuffer
    {
        private var _buffer:String;
        private var _bufferLines:Array;
        private var _response:SMTPResponse;
        private var _isFinished:Boolean;

        public function SMTPResponseBuffer()
        {
            _response    = null;
            _buffer      = "";
            _bufferLines = [];
            _isFinished  = false;
        }

        public function reset():void
        {
            _buffer      = "";
            _response    = null;
            _bufferLines = [];
            _isFinished  = false;
        }

        public function get isFinished():Boolean
        {
            return _isFinished;
        }

        public function pushBytes(bytes:ByteArray):void
        {
            if (_isFinished)
                return;

            bytes.position = 0;
            _buffer += bytes.readUTFBytes(bytes.length);

            while (!_isFinished) {
                var eol:int = _buffer.indexOf("\r\n");
                if (eol == -1) {
                    if (_buffer.length > 2048)
                        throw new SMTPResponseFormatError("Response line is too long: " + _buffer);
                    break;
                }
                var line:String = _buffer.substring(0, eol);
                _buffer = _buffer.substring(eol + 2);
                processLine(line);
            }
        }

        private function processLine(line:String):void
        {
            var matched:Array = line.match(/^(\d{3})(\-|\s)(.+)$/);
            if (matched == null)
                throw new SMTPResponseFormatError("Invalid response: " + line);

            _bufferLines.push(matched[3]);
            if (matched[2] != '-') { // is last line
                _isFinished = true;
                _response = new SMTPResponse(uint(matched[1]), _bufferLines);
            }
        }

        public function get response():SMTPResponse
        {
            return _response;
        }
    }
}

