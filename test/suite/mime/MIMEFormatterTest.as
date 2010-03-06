package suite.mime
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;
    import flash.utils.ByteArray;

    import com.hurlant.util.Base64;

    import org.coderepos.net.mime.MIMEFormatter;
    import org.coderepos.net.mime.MIMEMessage;
    import org.coderepos.net.mime.MIMEMailAddress;
    import org.coderepos.net.mime.MIMEPart;
    import org.coderepos.net.mime.MIMEParser;

    public class MIMEFormatterTest extends TestCase
    {
        public function MIMEFormatterTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new MIMEFormatterTest("testFormat"));
            return ts;
        }

        public function s2b(s:String):ByteArray
        {
            var b:ByteArray = new ByteArray();
            b.writeUTFBytes(s);
            return b;
        }

        public function testFormat():void
        {
            var formatter:MIMEFormatter = new MIMEFormatter();
            var msg:MIMEMessage = new MIMEMessage();
            msg.addTo(new MIMEMailAddress("Lyo Kato <lyo.kato@gmail.com>"));
            msg.from = new MIMEMailAddress("lyo.kato@gmail.com");
            msg.subject = "めっせーじてすと";
            msg.setText("あいうえお");
            var str:String = formatter.formatToString(msg);
            str = str.replace(/\r\n\.\r\n/, "");

            var parser:MIMEParser = new MIMEParser();
            var parsed:MIMEMessage = parser.parse(s2b(str));
            assertEquals('Lyo Kato <lyo.kato@gmail.com>', parsed.to[0].valueOf());
            assertEquals('lyo.kato@gmail.com', parsed.from.valueOf());
            assertEquals("めっせーじてすと", parsed.subject);
            assertTrue(parsed.isText);

            var b:ByteArray = new ByteArray();
            b.writeUTFBytes("あいうえお");
            b.position = 0;
            assertEquals('44GC44GE44GG44GI44GK', Base64.encodeByteArray(b));

            assertEquals("あいうえお", parsed.getText());
        }
    }
}

