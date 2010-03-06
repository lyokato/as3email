package org.coderepos.net.imap.data
{
    public class MailboxQuotaRoot
    {
        public var mailbox:String;
        public var quotaroots:Array;

        public function MailboxQuotaRoot(mailbox:String, quotaroots:Array)
        {
            this.mailbox = mailbox;
            this.quotaroots = quotaroots;
        }
    }
}
