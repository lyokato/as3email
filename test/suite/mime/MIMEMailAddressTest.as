package suite.mime
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;
    import flash.utils.ByteArray;

    import org.coderepos.net.mime.MIMEMailAddress;

    public class MIMEMailAddressTest extends TestCase
    {
        public function MIMEMailAddressTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new MIMEMailAddressTest("testPerson"));
            return ts;
        }

        public function testPerson():void
        {
            var person:MIMEMailAddress = MIMEMailAddress.parse("tanaka@example.com");
            assertNull("person.nickname is null", person.nickname);
            assertEquals("person.address", "tanaka@example.com", person.address);

            var personWithNick:MIMEMailAddress = MIMEMailAddress.parse("tanaka <tanaka@example.com>");
            assertEquals("[nick]person.nickname", "tanaka", personWithNick.nickname);
            assertEquals("[nick]person.address", "tanaka@example.com", personWithNick.address);
            //assertEquals("[nick]person.toHeaderValue(UTF8)", "tanaka <tanaka@example.com>", personWithNick.toHeaderValue("UTF-8"));
            //assertEquals("[nick]person.toHeaderValue(JIS)", "tanaka <tanaka@example.com>", personWithNick.toHeaderValue("ISO-2022-JP"));

            var personWithoutNick:MIMEMailAddress = MIMEMailAddress.parse("<tanaka@example.com>");
            assertNull('[no nick]nickname', personWithoutNick.nickname);
            assertEquals('[no nick]address', "tanaka@example.com", personWithoutNick.address);

            // this functionality moved to MIMEFormatter
            //var personWithMBNick:MIMEMailbox = MIMEMailbox.parse("田中 <tanaka@example.com>");
            //assertEquals("[mb]person.nickname", "田中", personWithMBNick.nickname);
            //assertEquals("[mb]person.address", "tanaka@example.com", personWithMBNick.address);
            //assertEquals("[mb]person.toHeaderValue(JIS)", "=?ISO-2022-JP?B?GyRCRURDZhsoQg==?=\r\n <tanaka@example.com>", personWithMBNick.toHeaderValue("ISO-2022-JP"));
            //assertEquals("[mb]person.toHeaderValue(UTF8)", "=?UTF-8?B?55Sw5Lit?=\r\n <tanaka@example.com>", personWithMBNick.toHeaderValue("UTF-8"));
        }
    }
}
