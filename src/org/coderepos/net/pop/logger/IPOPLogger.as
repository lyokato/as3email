package org.coderepos.net.pop.logger
{
    public interface IPOPLogger
    {
        function logRequest(req:String):void;
        function logResponse(res:String):void;
        function logFormatError(src:String):void;
    }
}

