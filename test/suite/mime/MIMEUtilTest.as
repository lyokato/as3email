package suite {
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;
    import flash.utils.ByteArray;

    import org.coderepos.net.mime.MIMEUtil;

    public class MIMEUtilTest extends TestCase
    {
        public function MIMEUtilTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new MIMEUtilTest("testDecodeHeaderValue"));
            ts.addTest(new MIMEUtilTest("testEncodeHeaderValue"));
            return ts;
        }

        public function testEncodeHeaderValue():void
        {
            var decoded:String = MIMEUtil.encodeHeaderValue("あいうえお　かきくけこ　さしすせそ　たちつてと　なにぬねの　はひふへほ　まみむめも　やゆよ アイウエオ カキクケコ サシスセソ タチツテト", "UTF-8");
            assertEquals('decode', '=?UTF-8?B?44GC44GE44GG44GI44GK44CA44GL44GN44GP44GR44GT44CA44GV44GX44GZ44Gb44Gd44CA44Gf44Gh44Gk44Gm44Go44CA44Gq44Gr?=\r\n =?UTF-8?B?44Gs44Gt44Gu44CA44Gv44Gy44G144G444G744CA44G+44G/44KA44KB44KC44CA44KE44KG44KIIOOCouOCpOOCpuOCqOOCqiA=?=\r\n =?UTF-8?B?44Kr44Kt44Kv44Kx44KzIOOCteOCt+OCueOCu+OCvSDjgr/jg4Hjg4Tjg4bjg4g=?=', decoded);

            var origin:String = MIMEUtil.decodeHeaderValue(decoded);
            assertEquals('encode to origin', 'あいうえお　かきくけこ　さしすせそ　たちつてと　なにぬねの　はひふへほ　まみむめも　やゆよ アイウエオ カキクケコ サシスセソ タチツテト', origin);

        }

        public function testDecodeHeaderValue():void
        {
            var origin:String = "田中 <tanaka@example.com>";
            var jisValue:String = "=?ISO-2022-JP?B?GyRCRURDZhsoQg==?=\r\n <tanaka@example.com>";
            var utfValue:String = "=?UTF-8?B?55Sw5Lit?=\r\n <tanaka@example.com>";

            var jisResult:String = MIMEUtil.decodeHeaderValue(jisValue);
            var utfResult:String = MIMEUtil.decodeHeaderValue(utfValue);

            assertEquals('decodeHeaderValue for jis', origin, jisResult);
            assertEquals('deocdeHeaderValue for utf', origin, utfResult);
        }

    }
}

