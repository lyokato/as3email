package org.coderepos.net.imap.data
{
    public class Address
    {
        public var name:String;
        public var route:String;
        public var mailbox:String;
        public var host:String;

        public function Address(name:String, route:String, mailbox:String, host:String)
        {
            this.name    = name;
            this.route   = route;
            this.mailbox = mailbox;
            this.host    = host;
        }
    }
}
