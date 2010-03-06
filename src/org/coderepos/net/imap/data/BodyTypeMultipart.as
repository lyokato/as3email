package org.coderepos.net.imap.data
{
    public class BodyTypeMultipart
    {
        public var mediaType:String;
        public var subType:String;
        public var parts:Array;
        public var param:Object;
        public var disposition:ContentDisposition;
        public var language:Array;
        public var extension:Array;

        public function BodyTypeMultipart(mediaType:String, subType:String, parts:Array, param:Object, disposition:ContentDisposition, language:Array, extension:Array)
        {
            this.mediaType = mediaType;
            this.subType = subType;
            this.parts = parts;
            this.param = param;
            this.disposition = disposition;
            this.language = language;
            this.extension = extension;
        }

        public function get isMultipart():Boolean
        {
            return true;
        }
    }
}
