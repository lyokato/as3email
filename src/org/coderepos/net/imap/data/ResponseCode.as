package org.coderepos.net.imap.data
{
    public class ResponseCode
    {
        public var name:String;
        public var data:*;

        public function ResponseCode(name:String, data:*)
        {
            this.name = name;
            this.data = data;
        }
    }
}
