package org.coderepos.net.mime
{
    import flash.utils.ByteArray;

    import com.adobe.utils.DateUtil;

    import org.coderepos.net.mime.exceptions.MIMEFormatError;
    import org.coderepos.net.mime.mediatype.MediaType;

    // RFC2138
    public class ContentDisposition
    {
        private var _type:String; // ContentDispositionType
        private var _filename:String;
        private var _creationDate:Date;
        private var _modificationDate:Date;
        private var _readDate:Date;
        private var _size:uint;

        public function ContentDisposition(type:String=null)
        {
            _type = (type == null) ? ContentDispositionType.INLINE : type;
            _size = 0;
        }

        public function get type():String
        {
            return _type;
        }

        public function get filename():String
        {
            return _filename;
        }

        public function set filename(name:String):void
        {
            _filename = name;
        }

        public function get creationDate():Date
        {
            return _creationDate;
        }

        public function set creationDate(date:Date):void
        {
            _creationDate = date;
        }

        public function get modificationDate():Date
        {
            return _modificationDate;
        }

        public function set modificationDate(date:Date):void
        {
            _modificationDate = date;
        }

        public function get readDate():Date
        {
            return _readDate;
        }

        public function set readDate(date:Date):void
        {
            _readDate = date;
        }

        public function get size():uint
        {
            return _size;
        }

        public function set size(s:uint):void
        {
            _size = s;
        }

    }
}

