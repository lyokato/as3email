package org.coderepos.net.smtp.logger
{
    public class SMTPNullLogger implements ISMTPLogger
    {
        public function SMTPNullLogger()
        {

        }

        public function logRequest(req:String):void
        {
            // do nothing
        }

        public function logResponse(res:String):void
        {
            // do nothing
        }
    }
}
