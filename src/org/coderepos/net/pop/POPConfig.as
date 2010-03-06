package org.coderepos.net.pop
{
    public class POPConfig
    {
        public var username:String;
        public var password:String;
        public var useAPOP:Boolean;
        public var storeOnServer:Boolean;
        public var expiration:uint;
        public var overTLS:Boolean;
        public var host:String;
        public var port:uint;
        public var timeout:uint;

        public function POPConfig()
        {
            username       = "";
            password       = "";
            useAPOP        = false;
            storeOnServer  = false;
            overTLS        = false;
            host           = "";
            port           = 110;
            expiration     = 60 * 60 * 24 * 15;
            timeout        = 30 * 1000;
        }
    }
}

