package org.coderepos.net.imap.data
{
    public class Envelope
    {
        public var date:String;
        public var subject:String;
        public var from:Array;
        public var sender:Array;
        public var replyTo:Array;
        public var to:Array;
        public var cc:Array;
        public var bcc:Array;
        public var inReplyTo:String;
        public var messageID:String;

        public function Envelope(
            date:String,
            subject:String,
            from:Array,
            sender:Array,
            replyTo:Array,
            to:Array,
            cc:Array,
            bcc:Array,
            inReplyTo:String,
            messageID:String
        )
        {
            this.date = date;
            this.subject = subject;
            this.from = from;
            this.sender = sender;
            this.replyTo = replyTo;
            this.to = to;
            this.cc = cc;
            this.bcc = bcc;
            this.inReplyTo = inReplyTo;
            this.messageID = messageID;
        }
    }
}
