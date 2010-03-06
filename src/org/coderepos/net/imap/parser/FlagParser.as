package org.coderepos.net.imap.parser
{
    public class FlagParser {

        public static function parse(src:String):FlagParserResult {
            var res:Array = src.match(/\(([^)]*)\)/);
            if (res == null)
                return null;
            var pos:uint = src.indexOf(res[0]) + res[0].length;
            var s:String = res[1];
            var p:RegExp = new RegExp(Patterns.FLAG, "g");
            var r:Array = p.exec(s);
            var flags:Array = new Array();
            while (r!=null) {
                flags.push(r[1]||capitalize(r[2]));
                r = p.exec(s);
            }
            return new FlagParserResult(pos, flags);
        }

        public static function capitalize(s:String):String
        {
            var first:String = s.charAt(0).toUpperCase();
            var rest:String = s.substring(1);
            return first + rest;
        }

    }
}
