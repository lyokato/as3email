package org.coderepos.net.mime.encoder
{
    import flash.utils.ByteArray;
    import com.hurlant.util.Hex;

    public class QuotedPrintableEncoder implements IMIMEEncoder
    {
        private var _lineLength:uint;
        private var _maxLineLength:uint;

        public function QuotedPrintableEncoder(lineLength:uint=60, maxLineLength:uint=72)
        {
            if (_lineLength > maxLineLength)
                throw new Error("lineLength should be under maxLineLength");
            _lineLength = lineLength;

            if (maxLineLength > 72)
                throw new Error("line length should be under 72.");
            _maxLineLength = maxLineLength;
        }

        public function get initial():String
        {
            return "Q";
        }

        public function get encodingName():String
        {
            return "quoted-printable";
        }

        public function encode(src:ByteArray):String
        {
            var result:String  = "";
            var temp:int       = 0;
            var lineLength:int = 0;

            src.position = 0;

            var c:uint;
            var next:uint;

            while (src.bytesAvailable > 0) {

                c = src.readUnsignedByte();

                if (c == 0x09 || c == 0x20) { // tab and space
                    var tabspaceBuf:String = String.fromCharCode(c);
                    while (src.bytesAvailable > 0) {
                        temp = src.position;
                        next = src.readUnsignedByte();
                        if (next == 0x09 || next == 0x20) {
                            tabspaceBuf += String.fromCharCode(next);
                            continue;
                        } else if (next == 0x0D) {
                            if (src.bytesAvailable > 0
                            && src.readUnsignedByte() == 0x0A) {
                                // need encoding for tab/space
                                //if (isBinary) {
                                    var len:int = tabspaceBuf.length;
                                    for (var i:int = 0; i < len; i++) {
                                        result += encodeByte(tabspaceBuf.charCodeAt(i));
                                        lineLength += 3;
                                    }
                                //}
                                // push CRLF to buffer
                                result += "\r\n";
                                lineLength = 0;
                                break;
                            } else {
                                // push tab/space without encoding
                                result += tabspaceBuf;
                                result += encodeByte(0x0D);
                                lineLength += tabspaceBuf.length + 3;
                                tabspaceBuf = "";
                                src.position = temp + 1;
                                if (lineLength > _lineLength) {
                                    result += "=\r\n";
                                    lineLength = 0;
                                }
                                break;
                            }
                        } else {
                            // push tab/space without encoding
                            result += tabspaceBuf;
                            lineLength += tabspaceBuf.length;
                            tabspaceBuf = "";
                            src.position--;
                            if (lineLength > _lineLength) {
                                result += "=\r\n";
                                lineLength = 0;
                            }
                            break;
                        }
                    }
                } else if (c == 0x0D) { // CR
                    temp = src.position;
                    if (src.bytesAvailable > 0
                    && (src.readUnsignedByte() == 0x0A)) {
                        result += "\r\n";
                        lineLength = 0;
                    } else {
                        result += encodeByte(0x0D);
                        lineLength += 3;
                        src.position = temp;
                    }
                } else if (c == 0x0A) {
                    result += encodeByte(0x0A);
                    lineLength += 3;
                } else if (c == 0x3D || c > 0x7e) {
                    result += encodeByte(c);
                    lineLength += 3;
                } else if (c < 0x20) {
                    //if (isBinary) {
                        result += encodeByte(c);
                        lineLength += 3;
                    //}
                } else {
                    result += String.fromCharCode(c);
                    lineLength++;
                }

                if (lineLength > _maxLineLength) {
                    result += "=\r\n";
                    lineLength = 0;
                }
            }
            return result;
        }

        private function encodeByte(byte:int):String
        {
            var encoded:String = Number(byte).toString(16).toUpperCase();
            if (encoded.length == 1) {
                encoded = "0" + encoded;
            }
            return "=" + encoded;
        }

        public function decode(src:String):ByteArray
        {
            var result:ByteArray = new ByteArray();
            var len:int = src.length;
            for (var i:int = 0; i < len;) {
                var c:int = src.charCodeAt(i++);
                if (c == 0x3D) {
                    if (src.length < i + 2) {
                        //throw new Error("Invalid quoted-printable format (found '=' but not have enough length): " + src);
                        result.position = 0;
                        return result;
                    }
                    var next1:int = src.charCodeAt(i++);
                    var next2:int = src.charCodeAt(i++);
                    if (next1 == 0x0D && next2 == 0x0A) {
                        // do nothing
                    } else {
                        var str1:String = String.fromCharCode(next1);
                        var str2:String = String.fromCharCode(next2);
                        if (   str1.match(/^[a-fA-F0-9]$/) == null
                            || str2.match(/^[a-fA-F0-9]$/) == null) {
                            //throw new Error("Invalid quoted-printable format (found '=' but invalid char follows): [" + str1 + "][" + str2 + "]");
                            result.position = 0;
                            return result;
                        }
                        var arr:ByteArray = Hex.toArray(str1 + str2);
                        result.writeBytes(arr, 0, arr.length);
                    }
                } else {
                    result.writeByte(c);
                }
            }
            result.position = 0;
            return result;
        }
    }
}

