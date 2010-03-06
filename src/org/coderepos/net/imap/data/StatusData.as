package org.coderepos.net.imap.data
{
    public class StatusData
    {
        public var mailbox:String;
        public var attr:Object;

        public function StatusData(mailbox:String, attr:Object)
        {
            this.mailbox = mailbox;
            this.attr = attr;
        }
    }
}
