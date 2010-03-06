package org.coderepos.net.imap.parser
{
    import org.coderepos.net.imap.data.Address;

    public class AddressParser
    {
        public static function parse(src:String):AddressParserResult
        {
            var res:Array = src.match(new RegExp(Patterns.ADDRESS));
            if (res == null)
                return null;
            var pos:uint = src.indexOf(res[0]) + res[0].length;
            var name:String    = filter(res[1]);
            var route:String   = filter(res[2]);
            var mailbox:String = filter(res[3]);
            var host:String    = filter(res[4]);

            var address:Address = new Address(name, route, mailbox, host);
            return new AddressParserResult(pos, address);
        }

        public static function filter(src:String):String
        {
            return src.replace(/\\(["\\])/g, "$1");
        }
    }

}
