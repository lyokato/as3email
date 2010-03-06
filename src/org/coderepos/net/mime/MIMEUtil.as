package org.coderepos.net.mime
{
    import flash.utils.ByteArray;

    public class MIMEUtil
    {
        public static function genMessageID(host:String=null):String
        {
            var id:String = "<";
            var now:Date = new Date();
            id += pushZero(now.fullYear, 4);
            id += pushZero(now.month + 1, 2);
            id += pushZero(now.date, 2);
            id += pushZero(now.hours, 2);
            id += pushZero(now.minutes, 2);
            id += pushZero(now.seconds, 2);
            id += ".";
            id += genRandom(8).toUpperCase();
            id += "@";
            if (host != null && host.length > 0)
                id += host;
            id += ">";
            return id;
        }

        public static function genRandom(digit:uint):String
        {
            var seeds:String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
            var result:String = "";
            for (var i:int = 0; i < digit; i++) {
                var index:int = Math.floor(Math.random() * seeds.length);
                result += seeds.charAt(index);
            }
            return result;
        }

        public static function parseMessageID(str:String):String
        {
            var start:int = str.indexOf("<");
            if (start == -1)
                return null;
            str = str.substring(start);
            var end:int = str.indexOf(">");
            if (end == -1)
                return null;
            var id:String = str.substring(start, end);
            return (id.length > 0) ? id : null;
        }

        public static function parseReferences(str:String):Array
        {
            var ids:Array = [];
            var start:int;
            var end:int;
            while (str.length > 0) {
                start = str.indexOf("<");
                if (start == -1)
                    break;
                str = str.substring(start);
                end = str.indexOf(">");
                if (end == -1)
                    break;
                var id:String = str.substring(0, end);
                str = str.substring(end);
                if (id.length > 0)
                    ids.push(id);
            }
            return ids;
        }

        public static function pushZero(num:Number, digit:uint):String
        {
            var s:String = String(num);
            while (s.length < digit)
                s = "0" + s;
            return s;
        }

        public static function genBoundary():String
        {
            return "----" + genRandom(12);
        }

        public static function CRLF2LF(str:String):String
        {
            return str.replace(/\r\n/, "\n");
        }

        public static function LF2CRLF(str:String):String
        {
            return str.replace(/[^\r]?\n/g, "\r\n");
        }

        public static function isASCII(str:String):Boolean
        {
            return (str.match(/^[\x01-\x7f]+$/) != null);
        }

    }
}

