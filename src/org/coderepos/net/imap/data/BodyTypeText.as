package org.coderepos.net.imap.data
{
    public class BodyTypeText
    {
        public var mediaType:String;
        public var subType:String;
        public var param:Object;
        public var contentID:String;
        public var description:String;
        public var encoding:String;
        public var size:Number;
        public var lines:Number;
        public var md5:String;
        public var disposition:ContentDisposition;
        public var language:Array;
        public var extension:Array;

        public function BodyTypeText(
            mediaType:String,
            subType:String,
            param:Object,
            contentID:String,
            description:String,
            encoding:String,
            size:Number,
            lines:Number,
            md5:String,
            disposition:ContentDisposition,
            langauge:Array,
            extension:Array
        )
        {
            this.mediaType = mediaType;
            this.subType = subType;
            this.param = param;
            this.contentID = contentID;
            this.description = description;
            this.encoding = encoding;
            this.size = size;
            this.lines = lines;
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
