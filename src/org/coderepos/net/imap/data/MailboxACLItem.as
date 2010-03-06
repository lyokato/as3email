package org.coderepos.net.imap.data
{
    public class MailboxACLItem
    {
        public var user:String;
        public var rights:String;

        public function MailboxACLItem(user:String, rights:String)
        {
            this.user = user;
            this.rights = rights;
        }
    }
}

