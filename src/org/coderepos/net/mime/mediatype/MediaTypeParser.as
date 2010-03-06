package org.coderepos.net.mime.mediatype
{
    import com.adobe.utils.StringUtil;
    import org.coderepos.net.mime.utils.HeaderValueDecoder;
    import org.coderepos.net.mime.utils.RFC2231Decoder;

    public class MediaTypeParser
    {
        private var _headerValueDecoder:HeaderValueDecoder;
        private var _rfc2231Decoder:RFC2231Decoder;

        public function MediaTypeParser(
            headerValueDecoder:HeaderValueDecoder,
            rfc2231Decoder:RFC2231Decoder)
        {
            _headerValueDecoder = headerValueDecoder;
            _rfc2231Decoder     = rfc2231Decoder;
        }

        private function getDecoderFor(str:String):IMediaTypeLineDecoder
        {
            if (str.match(/\=\?(.+)\?\=/) != null)
                return _headerValueDecoder;

            if (str.match(/^([^\']+)\'([^\']+)?\'(.+)$/) != null)
                return _rfc2231Decoder;

            return null;
        }

        public function parse(value:String):MediaType
        {
            var params:Object = {};
            var encodedSeqParams:Object = {};
            var name:String;
            var match:Array;

            var parts:Array = value.split(/\;/);
            var value:String = StringUtil.trim(parts.shift());

            var mediaType:MediaType = new MediaType(value.toLowerCase());

            var len:int = parts.length;
            for (var i:int = 0; i < len; i++) {
                var p:Object = parseParams(StringUtil.trim(parts[i]));
                if (p != null) {
                    if ((match = p.key.match(/^([^\*]+)\*(\d+)\*?$/)) != null) {
                        name = match[1];
                        var seq:uint = uint(match[2]);
                        if (!(name in encodedSeqParams)) {
                            encodedSeqParams[name] = [];
                        }
                        encodedSeqParams[name][seq] = p.value;
                    } else {
                        if ((match = p.key.match(/^([^\*]+)\*$/)) != null) {
                            name = match[1];
                        } else {
                            name = p.key;
                        }
                        mediaType.addParam(name, decodeLine(p.value));
                    }
                }
            }

            for (var prop:String in encodedSeqParams) {
                var arr:Array = encodedSeqParams[prop];
                var str:String = arr.join('');
                mediaType.addParam(prop, decodeLine(str));
            }
            return mediaType;
        }

        public function parseParams(param:String):Object
        {
            var eIndex:int = param.indexOf("=");
            if (eIndex == -1 || eIndex == 0)
                return null;

            var key:String = StringUtil.trim(param.substring(0, eIndex));
            if (key.length == 0)
                return null;

            if (eIndex + 1 >= param.length)
                return null;

            var rest:String = param.substring(eIndex+1);
            rest = StringUtil.trim(rest);
            var restLength:int = rest.length;
            if (restLength == 0)
                return null;

            var first:String = rest.charAt(0);
            var value:String;
            if (first == "'" || first == '"') {
                if (restLength == 1) {
                    return null;
                } else if (restLength == 2) {
                    var ch:String = rest.charAt(1);
                    if (ch == first)
                        value = "";
                    else
                        value = ch;
                } else {
                    var last:String = rest.charAt(restLength - 1);
                    if (last == first) {
                        value = rest.substring(1, restLength - 1);
                    } else {
                        value = rest.substring(1);
                    }
                }
            } else {
                value = rest;
            }
            return { key: key.toLowerCase(), value: value };
        }

        public function decodeLine(str:String):String
        {
            var decoder:IMediaTypeLineDecoder = getDecoderFor(str);
            if (decoder == null)
                return str;
            return decoder.decodeLine(str);
        }
    }
}

