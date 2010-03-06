package org.coderepos.net.mime.encoder
{
    import flash.utils.ByteArray;

    public interface IMIMEEncoder
    {
        function get initial():String;
        function get encodingName():String;
        function encode(src:ByteArray):String;
        function decode(src:String):ByteArray;
    }
}
