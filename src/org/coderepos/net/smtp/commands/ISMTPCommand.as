package org.coderepos.net.smtp.commands
{
    import flash.utils.ByteArray;

    public interface ISMTPCommand
    {
        function toByteArray():ByteArray;
        function valueOf():String;
    }
}

