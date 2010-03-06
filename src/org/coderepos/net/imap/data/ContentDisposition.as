package org.coderepos.net.imap.data
{
    public class ContentDisposition
    {
        public var dspType:String;
        public var param:Object;

        public function ContentDisposition(dspType:String, param:Object)
        {
            this.dspType = dspType;
            this.param   = param;
        }
    }
}
