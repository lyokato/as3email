package org.coderepos.net.smtp.exceptions
{
    public class SMTPResponseFormatError extends Error
    {
        public function SMTPResponseFormatError(msg:String)
        {
            super(msg);
        }
    }
}
