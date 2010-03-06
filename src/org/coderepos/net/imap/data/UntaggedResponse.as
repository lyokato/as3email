package org.coderepos.net.imap.data
{
    public class UntaggedResponse
    {
        public var name:String;
        public var data:*;
        public var rawData:String;

        public function UntaggedResponse(name:String, data:*, rawData:String)
        {
            this.name = name;
            this.data = data;
            this.rawData = rawData;
        }
    }
}
