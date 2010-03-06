package suite.mime
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;
    import flash.utils.ByteArray;
    import com.hurlant.util.Base64;
    import org.coderepos.net.mime.mediatype.MediaType;
    import org.coderepos.net.mime.mediatype.MediaTypeParser;
    import org.coderepos.net.mime.utils.HeaderValueDecoder;
    import org.coderepos.net.mime.utils.RFC2231Decoder;
    import org.coderepos.net.mime.encoder.MIMEEncoderFactory;
    import org.coderepos.net.mime.encoder.Base64Encoder;
    import org.coderepos.net.mime.encoder.QuotedPrintableEncoder;
    import org.coderepos.net.mime.charset.IMIMECharsetEncoder;
    import org.coderepos.net.mime.charset.MIMEDefaultCharsetEncoder;

    public class MediaTypeParserTest extends TestCase
    {
        public function MediaTypeParserTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new MediaTypeParserTest("testParse"));
            return ts;
        }

        public function testParse():void
        {
            var parser:MediaTypeParser = createParser();
            var res:MediaType = parser.parse("text/plain; charset='UTF-8'");
            assertEquals('res.type', 'text/plain', res.type);
            assertEquals('res.getParam("charset")', 'UTF-8', res.getParam('charset'));

            // loose parameter
            var res2:MediaType = parser.parse("text/plain; charset=iso-2022-jp");
            assertEquals('res.type[loose]', 'text/plain', res2.type);
            assertEquals('res.getParam("charset")[loose]', 'iso-2022-jp', res2.getParam('charset'));

            // MIMEB-Encoding
            var res3:MediaType = parser.parse('text/plain; charset=iso-2022-jp; name="=?UTF-8?B?44GC44GE44GG44GI44GKVVRGOOOBquODleOCoeOCpOODq+WQjS50eHQ=?="');
            assertEquals('text/plain', res3.type);
            assertEquals('iso-2022-jp', res3.getParam('charset'));
            assertEquals('あいうえおUTF8なファイル名.txt', res3.getParam('name'));

            // Content-Disposition style with MIMEB-Encoding
            var res4:MediaType = parser.parse('attachment; filename="=?ISO-2022-JP?B?GyRCJF4kJCRhGyhCLnR4dA==?=');
            assertEquals('attachment', res4.type);
            assertEquals('まいめ.txt', res4.getParam('filename'));

            // Content-Disposition style with RFC2231-Encoding
            var res5:MediaType = parser.parse("inline; filename*=iso-2022-jp''%1B%24B%3CL%3F%3F%1B%28B.jpg");
            assertEquals('inline', res5.type);
            assertEquals('写真.jpg', res5.getParam('filename'));

            // Multiline parameter ASCII
            var res6:MediaType = parser.parse("application/x-stuff; "
                +"title*0*=us-ascii'en'This%20is%20even%20more%20; "
                +"title*1*=%2A%2A%2Afun%2A%2A%2A%20; "
                +"title*2=\"isn't it!\"");
            assertEquals('parseMediaType value6', 'application/x-stuff', res6.type);
            assertEquals('parseMediaType params6', "This is even more ***fun*** isn't it!", res6.getParam('title'));

            // Multiline parameter UTF-8
            var res7:MediaType = parser.parse("inline;"
             + "filename*0*=UTF-8''%E3%81%82%E3%81%84%E3%81%86%E3%81%88%E3%81%8A%55%54%46;"
             + "filename*1*=%38%E3%81%AA%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E5%90%8D%2E;"
             + "filename*2*=%74%78%74");
            assertEquals('res7.value', 'inline', res7.type);
            assertEquals('res7.params', 'あいうえおUTF8なファイル名.txt', res7.getParam('filename'));

            var res8:MediaType = parser.parse("inline;"
             + "filename*0*=UTF-8''%E3%81%82%E3%81%84%E3%81%86%E3%81%88%E3%81%8A%55%54%46;"
             + "filename*2*=%38%E3%81%AA%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E5%90%8D%2E;"
             + "filename*3*=%74%78%74");
            assertEquals('res8.value', 'inline', res8.type);
            assertEquals('res8.params', 'あいうえおUTF8なファイル名.txt', res8.getParam('filename'));

        }

        public function createParser():MediaTypeParser
        {
            var b64Encoder:Base64Encoder = new Base64Encoder();
            var qpEncoder:QuotedPrintableEncoder = new QuotedPrintableEncoder();
            var charsetEncoder:IMIMECharsetEncoder = new MIMEDefaultCharsetEncoder();
            var encoderFactory:MIMEEncoderFactory = new MIMEEncoderFactory(b64Encoder, qpEncoder);
            var headerValueDecoder:HeaderValueDecoder = new HeaderValueDecoder(encoderFactory, charsetEncoder);
            var rfc2231Decoder:RFC2231Decoder = new RFC2231Decoder(charsetEncoder);
            var parser:MediaTypeParser = new MediaTypeParser(headerValueDecoder, rfc2231Decoder);
            return parser;
        }

    }
}
