package suite.smtp
{
    import flash.utils.ByteArray;
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.net.smtp.SMTPResponseBuffer;
    import org.coderepos.net.smtp.SMTPResponse;
    import org.coderepos.net.smtp.exceptions.SMTPResponseFormatError;

    public class SMTPResponseBufferTest extends TestCase
    {
        public function SMTPResponseBufferTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new SMTPResponseBufferTest("testBuffer"));
            ts.addTest(new SMTPResponseBufferTest("testBufferInvalid"));
            return ts;
        }

        public function testBufferInvalid():void
        {
            var buffer:SMTPResponseBuffer = new SMTPResponseBuffer();
            var errorOccured:Boolean = false;
            try {
                buffer.pushBytes(s2b("smtp.example.org\r\n"));
            } catch (e:SMTPResponseFormatError) {
                errorOccured = true;
            }

            assertTrue('error should occur', errorOccured);
        }

        public function testBuffer():void
        {
            var buffer:SMTPResponseBuffer = new SMTPResponseBuffer();
            buffer.pushBytes(s2b("250-smtp.example.org\r\n"));
            assertFalse('not finished', buffer.isFinished);
            buffer.pushBytes(s2b("250 DSN\r\n"));
            assertTrue('finished', buffer.isFinished);
            var res:SMTPResponse = buffer.response;
            assertEquals('code', 250, res.code);
            assertEquals('line length', 2, res.lines.length);
            assertEquals('first line', 'smtp.example.org', res.lines[0]);
            assertEquals('second line', 'DSN', res.lines[1]);
        }

        private function s2b(str:String):ByteArray
        {
            var b:ByteArray = new ByteArray();
            b.writeUTFBytes(str);
            b.position = 0;
            return b;
        }

    }
}
