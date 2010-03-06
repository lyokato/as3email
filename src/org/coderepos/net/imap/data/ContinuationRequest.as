package org.coderepos.net.imap.data
{
    public class ContinuationRequest
    {
        public var data:ResponseText;
        public var rawData:String;

        public function ContinuationRequest(data:ResponseText, rawData:String)
        {
            this.data = data;
            this.rawData = rawData;
        }
    }
}
