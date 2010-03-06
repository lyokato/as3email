package org.coderepos.net.mime.utils
{
    import org.coderepos.net.mime.mediatype.IMediaTypeLineDecoder;
    import org.coderepos.net.mime.encoder.MIMEEncoderFactory;
    import org.coderepos.net.mime.encoder.IMIMEEncoder;
    import org.coderepos.net.mime.charset.IMIMECharsetEncoder;
    import com.adobe.utils.StringUtil;

    public class HeaderValueDecoder implements IMediaTypeLineDecoder
    {
        private var _encoderFactory:MIMEEncoderFactory;
        private var _charsetEncoder:IMIMECharsetEncoder;

        public function HeaderValueDecoder(
            encoderFactory:MIMEEncoderFactory,
            charsetEncoder:IMIMECharsetEncoder)
        {
            _encoderFactory = encoderFactory;
            _charsetEncoder = charsetEncoder;
        }

        // maybe no needed
        public function decode(value:String):String
        {
            var lines:Array = value.split(/\r\n/);
            var len:int = lines.length;
            var line:String;
            var result:String = "";

            for (var i:uint = 0; i < len; i++) {
                result += decodeLine(StringUtil.trim(lines[i]));
            }
            return result;
        }

        public function decodeLine(line:String):String
        {
            return line.replace(/\=\?([^\?]+)\?(B|Q)\?([^\?]+)\?\=/gi, function():String {
                var charset:String = arguments[1].toUpperCase();
                var initial:String = arguments[2].toUpperCase();
                var data:String    = arguments[3];

                var encoder:IMIMEEncoder =
                    _encoderFactory.getByInitial(initial);
                if (encoder == null) {
                    //XXX: throw new MIMEFormatError();
                    return arguments[0];
                }
                return _charsetEncoder.decode(encoder.decode(data), charset);
            });
        }
    }
}

