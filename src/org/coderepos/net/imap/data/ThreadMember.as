package org.coderepos.net.imap.data
{
    public class ThreadMember
    {
        public var seqno:Number;
        public var children:Array;

        public function ThreadMember(seqno:Number, children:Array)
        {
            this.seqno = seqno;
            this.children = children;
        }
    }
}
