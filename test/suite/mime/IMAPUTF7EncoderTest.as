package suite.mime
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;
    import flash.utils.ByteArray;
    import com.hurlant.util.Base64;
    import org.coderepos.text.encoding.Jcode;
    import org.coderepos.net.mime.utils.IMAPUTF7Encoder;

    public class IMAPUTF7EncoderTest extends TestCase
    {
        public function IMAPUTF7EncoderTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new IMAPUTF7EncoderTest("testB64"));
            ts.addTest(new IMAPUTF7EncoderTest("testUTF7IMAP"));
            return ts;
        }

        public function testB64():void
        {
            testB64Word("日本語");
            testB64Word("ほげほげ");
            testB64Word("abcdeほげほげ");
            testB64Word("abcdeほげほげefg");
        }

        public function testB64Word(s:String):void
        {
            var origin:ByteArray = new ByteArray();
            origin.writeUTFBytes(s);
            origin.position = 0;
            var encoded:String = IMAPUTF7Encoder.encodeModifiedBase64(origin);
            var decoded:ByteArray = IMAPUTF7Encoder.decodeModifiedBase64(encoded);
            decoded.position = 0;
            assertEquals(s, decoded.readUTFBytes(decoded.length));
        }

        public function testUTF7IMAP():void
        {
            var utf7i:String = IMAPUTF7Encoder.encode("INBOX.日本語");
            assertEquals('encode', 'INBOX.&ZeVnLIqe-', utf7i);
            assertEquals('decode', 'INBOX.日本語', IMAPUTF7Encoder.decode('INBOX.&ZeVnLIqe-'));
        }

    }
}
