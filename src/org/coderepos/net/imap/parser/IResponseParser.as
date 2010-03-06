package org.coderepos.net.imap.parser
{
    public interface IResponseParser
    {
        function parse(command:String):*;
    }
}
