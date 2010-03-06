package org.coderepos.net.imap.data
{
    public class TaggedResponse
    {
        public var tag:String;
        public var name:String;
        public var data:*;
        public var rawData:String;

        public function TaggedResponse(tag:String, name:String, data:*,
            rawData:String)
        {
            this.tag     = tag;
            this.name    = name;
            this.data    = data;
            this.rawData = rawData;
        }
    }
}

