package suite.mime
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;
    import flash.utils.ByteArray;

    import org.coderepos.net.mime.encoder.QuotedPrintableEncoder;
    import org.coderepos.net.mime.encoder.IMIMEEncoder;

    public class QuotedPrintableTest extends TestCase
    {
        public function QuotedPrintableTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new QuotedPrintableTest("testByte"));
            ts.addTest(new QuotedPrintableTest("testEncoder"));
            return ts;
        }

        public function testEncoder():void
        {
            var encoder:IMIMEEncoder = new QuotedPrintableEncoder();

            var bytes:ByteArray = new ByteArray();
            bytes.writeUTFBytes("And it should be the law: If you use the word 'paradigm' without knowing what the dictionary says it means, you go to jail. No exceptions. ==> David Jones");
            bytes.position = 0;

            var str:String = encoder.encode(bytes);
            assertEquals('quoted printable', "And it should be the law: If you use the word 'paradigm' without =\r\nknowing what the dictionary says it means, you go to jail. No =\r\nexceptions. =3D=3D> David Jones", str);
            var decoded:ByteArray = encoder.decode(str);
            var decodedStr:String = decoded.readUTFBytes(decoded.length);
            assertEquals('quoted-printable decode', "And it should be the law: If you use the word 'paradigm' without knowing what the dictionary says it means, you go to jail. No exceptions. ==> David Jones", decodedStr);
        }

        public function testByte():void
        {
            var str:String = "a\tscii";
            var bytes:ByteArray = new ByteArray();
            bytes.writeUTFBytes(str);
            bytes.position = 0;
            var c:int   = bytes.readByte();
            var tab:int = bytes.readByte();
            assertEquals('tab byte', 0x09, tab);
            assertEquals('first byte', 0x61, c);

            var s:String = String.fromCharCode(c);
            assertEquals('decode from byte', 'a', s);
        }
    }
}

