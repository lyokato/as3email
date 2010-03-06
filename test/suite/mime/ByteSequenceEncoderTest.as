package suite.mime
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;
    import flash.utils.ByteArray;
    import com.hurlant.util.Base64;
    import org.coderepos.net.mime.charset.MIMEDefaultCharsetEncoder;
    import org.coderepos.net.mime.utils.ByteSequenceEncoder;

    public class ByteSequenceEncoderTest extends TestCase
    {
        public function ByteSequenceEncoderTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new ByteSequenceEncoderTest("testEncode"));
            return ts;
        }

        public function testEncode():void
        {
            var charset:MIMEDefaultCharsetEncoder = new MIMEDefaultCharsetEncoder();
            var encoded:String = ByteSequenceEncoder.encode(charset.encode("あいうえお.doc", "UTF-8"));
            assertEquals('utf-8 to byte seq', '%E3%81%82%E3%81%84%E3%81%86%E3%81%88%E3%81%8A.doc', encoded);
            var decoded:String = charset.decode(ByteSequenceEncoder.decode(encoded), "UTF-8");
            assertEquals('byteSequenceToUTF8', 'あいうえお.doc', decoded);

            var jisencoded:String = ByteSequenceEncoder.encode(charset.encode("ほごほげ.jpeg", "iso-2022-jp"));
            assertEquals('jis byte sequence encode', '%1B%24B%24%5B%244%24%5B%242%1B%28B.jpeg', jisencoded);

            var jisdecoded:String = charset.decode(ByteSequenceEncoder.decode(jisencoded), 'iso-2022-jp');
            assertEquals('jis byte sequence decode', 'ほごほげ.jpeg', jisdecoded);

            var jisdecoded2:String = charset.decode(ByteSequenceEncoder.decode("%1B%24B%21w%23I%23T%25m%254%25%5E%21%3C%25%2F%1B%28B%2Egif"), "iso-2022-jp");
            assertEquals('jis byte sequence decode', '＠ＩＴロゴマーク.gif', jisdecoded2);

            var ascii:String = charset.decode(ByteSequenceEncoder.decode("This%20is%20even%20more%20%2A%2A%2Afun%2A%2A%2A%20isn't it!"), "US-ASCII");
            assertEquals('ascii', "This is even more ***fun*** isn't it!", ascii);
        }

    }
}
