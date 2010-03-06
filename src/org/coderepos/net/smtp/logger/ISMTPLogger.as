package org.coderepos.net.smtp.logger
{
    public interface ISMTPLogger
    {
        function logRequest(req:String):void;
        function logResponse(res:String):void;
    }
}

