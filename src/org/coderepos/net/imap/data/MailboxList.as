package org.coderepos.net.imap.data
{
    public class MailboxList
    {
        public var attr:Array;
        public var delim:String;
        public var name:String;

        public function MailboxList(attr:Array, delim:String, name:String)
        {
            this.attr = attr;
            this.delim = delim;
            this.name = name;
        }
    }
}

