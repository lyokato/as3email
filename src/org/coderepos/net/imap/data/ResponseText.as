package org.coderepos.net.imap.data
{
    public class ResponseText
    {
        public var code:ResponseCode;
        public var text:String;

        public function ResponseText(code:ResponseCode, text:String)
        {
            this.code = code;
            this.text = text;
        }
    }
}
