package org.coderepos.net.pop
{
    import flash.utils.ByteArray;
    import com.adobe.utils.StringUtil;

    import org.coderepos.net.pop.exceptions.POPResponseFormatError;

    public class POPResponseBuffer implements IPOPResponseBuffer
    {
        private static const MAX_LINE_SIZE:uint = 512;

        private var _status:String;

        private var _buffer:ByteArray;
        private var _isError:Boolean;

        private var _targetID:String;
        private var _targetUID:String;

        private var _state:uint;

        public function POPResponseBuffer()
        {
            _buffer  = new ByteArray();
            _isError = false;
            _state   = 0;
        }

        public function pushBytes(bytes:ByteArray):void
        {
            if (_state == 7)
                return;

            if (_buffer.length + bytes.length > MAX_LINE_SIZE)
                throw new POPResponseFormatError("status line is over 512 bytes:");

            bytes.position = 0;

            var c:uint;

            BYTELOOP: while (bytes.bytesAvailable > 0) {
                c = bytes.readUnsignedByte();
                switch (_state) {
                    case 0:
                        if (c == 0x0d)
                            _state = 1;
                        else
                            _buffer.writeByte(c);
                        break;
                    case 1:
                        if (c == 0x0a) {
                            _state = 7;
                            _buffer.position = 0;
                            var temp:String = _buffer.readUTFBytes(_buffer.length);
                            _buffer.length = 0;
                            var matched:Array = temp.match(/^\+OK/);
                            if (matched != null) {
                                _status = (temp.length > 3) ? temp.substring(3) : "";
                                _status = StringUtil.trim(_status);
                            } else {
                                _isError = true;
                                matched = temp.match(/^\-ERR/);
                                if (matched != null) {
                                    _status = (temp.length > 4) ? temp.substring(4) : "";
                                    _status = StringUtil.trim(_status);
                                } else {
                                    throw new POPResponseFormatError(
                                        "Unknown response format: " + temp);
                                }
                            }
                            break BYTELOOP;
                        } else {
                            _buffer.writeByte(0x0d);
                            _state = 0;
                            bytes.position--;
                        }
                        break;
                }
            }

            bytes.length = 0;
        }

        public function get isFinished():Boolean
        {
            return (_state == 7);
        }

        public function get response():POPResponse
        {
            if (_state != 7)
                return null;

            var type:String = (_isError) ? POPResponse.ERR : POPResponse.OK;
            var res:POPResponse = new POPResponse(type, _status, null);
            if (_targetID != null)
                res.targetID = _targetID;
            if (_targetUID != null)
                res.targetUID = _targetUID;
            return res;
        }

        public function get buffer():String
        {
            var p:uint = _buffer.position;
            _buffer.position = 0;
            var res:String = _buffer.readUTFBytes(_buffer.length);
            _buffer.position = p;
            return res;
        }

        public function get targetID():String
        {
            return _targetID;
        }

        public function set targetID(id:String):void
        {
            _targetID = id;
        }

        public function get targetUID():String
        {
            return _targetUID;
        }

        public function set targetUID(id:String):void
        {
            _targetUID = id;
        }

        public function get state():uint
        {
            return _state;
        }
    }
}

