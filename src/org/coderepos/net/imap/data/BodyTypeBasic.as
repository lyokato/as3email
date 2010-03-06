package org.coderepos.net.imap.data
{
    public class BodyTypeBasic
    {

        public var mediaType:String;
        public var subType:String;
        public var param:Object;
        public var contentID:String;
        public var description:String;
        public var encoding:String;
        public var size:Number;
        public var md5:String;
        public var disposition:ContentDisposition;
        public var language:Array;
        public var extension:Array;

        public function BodyTypeBasic(
            mediaType:String,
            subType:String,
            param:Object=null,
            contentID:String=null,
            description:String=null,
            encoding:String=null,
            size:Number=0,
            md5:String=null,
            disposition:ContentDisposition=null,
            language:Array=null,
            extension:Array=null
        )
        {
            this.mediaType = mediaType;
            this.subType = subType;
            this.param = param;
            this.contentID = contentID;
            this.description = description;
            this.encoding = encoding;
            this.size = size;
            this.md5 = md5;
            this.disposition = disposition;
            this.language = language;
            this.extension = extension;
        }

        public function get isMultipart():Boolean
        {
            return false;
        }
    }
}
