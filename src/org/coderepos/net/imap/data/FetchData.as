package org.coderepos.net.imap.data
{
    public class FetchData
    {
        public var seqno:Number;
        public var attr:Object;

        public function FetchData(seqno:Number, attr:Object)
        {
            this.seqno = seqno;
            this.attr = attr;
        }
    }
}
