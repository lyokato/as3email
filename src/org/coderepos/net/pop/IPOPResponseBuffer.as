package org.coderepos.net.pop
{
    import flash.utils.ByteArray;

    public interface IPOPResponseBuffer
    {
        function pushBytes(bytes:ByteArray):void;
        function get state():uint;
        function get isFinished():Boolean;
        function get response():POPResponse;
        function get buffer():String;
        function get targetID():String;
        function get targetUID():String;
        function set targetID(id:String):void;
        function set targetUID(id:String):void;
    }
}

