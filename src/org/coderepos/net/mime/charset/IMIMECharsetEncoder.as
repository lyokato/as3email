package org.coderepos.net.mime.charset
{
    import flash.utils.ByteArray;

    public interface IMIMECharsetEncoder
    {
        function encode(src:String, charset:String):ByteArray;
        function decode(src:ByteArray, charset:String):String;
    }
}
