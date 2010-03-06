package org.coderepos.net.pop
{
    import flash.utils.ByteArray;
    import com.adobe.utils.StringUtil;

    import org.coderepos.net.pop.exceptions.POPResponseFormatError;

    public class POPMultipleLineResponseBuffer implements IPOPResponseBuffer
    {
        private static const MAX_DATA_SIZE:uint = 50 * 1024 * 1024;
        private static const MAX_LINE_SIZE:uint = 512;

        private var _status:String;
        private var _data:ByteArray;

        private var _buffer:ByteArray;
        private var _isError:Boolean;

        private var _targetID:String;
        private var _targetUID:String;

        private var _state:uint;

        public function POPMultipleLineResponseBuffer()
        {
            _buffer  = new ByteArray();
            _data    = null;
            _isError = false;
            _state   = 0;
        }

        public function pushBytes(bytes:ByteArray):void
        {
            if (_state == 7) {
                return;
            } else if (_state >= 2 && (bytes.length + _data.length > MAX_DATA_SIZE)) {
                throw new POPResponseFormatError("Response body is too large.");
            }

            bytes.position = 0;

            var c:uint;

            BYTELOOP: while (bytes.bytesAvailable > 0) {
                c = bytes.readUnsignedByte();
                switch (_state) {
                    case 0:
                        if (c == 0x0d) {
                            _state = 1;
                        } else {
                            if (_buffer.length > MAX_LINE_SIZE)
                                throw new POPResponseFormatError("Status line is too long.");
                            _buffer.writeByte(c);
                        }
                        break;
                    case 1:
                        if (c == 0x0a) {
                            _buffer.position = 0;
                            var temp:String = _buffer.readUTFBytes(_buffer.length);
                            _buffer.length = 0;
                            var matched:Array = temp.match(/^\+OK/);
                            if (matched != null) {
                                _state  = 2;
                                _status = (temp.length > 3) ? temp.substring(3) : "";
                                _status = StringUtil.trim(_status);
                                _data   = new ByteArray();
                            } else {
                                _state = 7;
                                _isError = true;
                                matched = temp.match(/^\-ERR/);
                                if (matched != null) {
                                    _status = (temp.length > 4) ? temp.substring(4) : "";
                                    _status = StringUtil.trim(_status);
                                } else {
                                    throw new POPResponseFormatError(
                                        "Unknown response format: " + temp);
                                }
                                break BYTELOOP;
                            }
                        } else {
                            _buffer.writeByte(0x0d);
                            _state = 0;
                            bytes.position--;
                        }
                        break;
                    case 2:
                        if (c == 0x0d)
                            _state = 3;
                        else
                            _data.writeByte(c);
                        break;
                    case 3:
                        if (c == 0x0a) {
                            _state = 4;
                        } else {
                            _data.writeByte(0x0d);
                            _state = 2;
                            bytes.position--;
                        }
                        break;
                    case 4:
                        if (c == 0x2e) {
                            _state = 5;
                        } else {
                            _data.writeByte(0x0d);
                            _data.writeByte(0x0a);
                            _state = 2;
                            bytes.position--;
                        }
                        break;
                    case 5:
                        if (c == 0x0d) {
                            _state = 6;
                        } else {
                            _data.writeByte(0x0d);
                            _data.writeByte(0x0a);
                            _data.writeByte(0x2e);
                            _state = 2;
                            bytes.position--;
                        }
                        break;
                    case 6:
                        if (c == 0x0a) {
                            _state = 7;
                            break BYTELOOP;
                        } else {
                            _data.writeByte(0x0d);
                            _data.writeByte(0x0a);
                            _data.writeByte(0x2e);
                            _data.writeByte(0x0d);
                            _state = 2;
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
            var res:POPResponse = new POPResponse(type, _status, _data);
            if (_targetID != null)
                res.targetID = _targetID;
            if (_targetUID != null)
                res.targetUID = _targetUID;
            return res;
        }

        public function get buffer():String
        {
            if (_data == null)
                return null;
            var p:uint = _data.position;
            _data.position = 0;
            var res:String = _data.readUTFBytes(_data.length);
            _data.position = p;
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

