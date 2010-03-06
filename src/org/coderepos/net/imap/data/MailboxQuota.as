package org.coderepos.net.imap.data
{
    public class MailboxQuota
    {
        public var mailbox:String;
        public var usage:String;
        public var quota:String;

        public function MailboxQuota(mailbox:String, usage:String, quota:String)
        {
            this.mailbox = mailbox;
            this.usage = usage;
            this.quota = quota;
        }
    }
}
