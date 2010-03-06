package org.coderepos.net.smtp
{
    public class SMTPConfig
    {
        public var host:String;
        public var port:uint;
        public var timeout:uint;
        public var overTLS:Boolean;
        public var localAddress:String;
        public var useSMTPAuth:Boolean;
        public var username:String;
        public var password:String;

        public function SMTPConfig()
        {
            host         = "";
            port         = 25;
            timeout      = 5000;
            overTLS      = false;
            localAddress = "localhost";
            useSMTPAuth  = false;
            username     = "";
            password     = "";
        }
    }
}

