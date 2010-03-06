package org.coderepos.net.pop.commands
{
    import flash.utils.ByteArray;

    public interface IPOPCommand
    {
        function get targetID():String;
        function get targetUID():String;
        function toByteArray():ByteArray;
        function valueOf():String;
        function get supportsMultiLineResponse():Boolean;
    }
}
