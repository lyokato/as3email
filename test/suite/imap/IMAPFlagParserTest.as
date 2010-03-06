package suite {
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.net.imap.parser.*;

    public class IMAPFlagParserTest extends TestCase
    {
        public function IMAPFlagParserTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new IMAPFlagParserTest("testFlagParser"));
            return ts;
        }

        public function testFlagParser():void
        {
            var s:String = "(\\Answered \\Seen)";
            var r:FlagParserResult = FlagParser.parse(s);
            assertNotNull(r);
            assertEquals('last index of match', '17', r.lastIndex);
            assertEquals('2 flags Answered and Seen matched', '2', r.flags.length);
            assertEquals('Answered', 'Answered', r.flags[0]);
            assertEquals('Seen', 'Seen', r.flags[1]);

            var invalid:String = " Hoge Hoge";
            r = FlagParser.parse(invalid);
            assertNull(r);

            s = "(\\Answered \\Seen \\*)";
            r = FlagParser.parse(s);
            assertNotNull(r);
            assertEquals('last index of match', '20', r.lastIndex);
            assertEquals('3 flags Answered and Seen matched', '3', r.flags.length);
            assertEquals('Answered', 'Answered', r.flags[0]);
            assertEquals('Seen', 'Seen', r.flags[1]);
            assertEquals('*', '*', r.flags[2]);

            s = "(answered seen)";
            r = FlagParser.parse(s);
            assertNotNull(r);
            assertEquals('last index of match', '15', r.lastIndex);
            assertEquals('2 flags Answered and Seen matched', '2', r.flags.length);
            assertEquals('Answered', 'Answered', r.flags[0]);
            assertEquals('Seen', 'Seen', r.flags[1]);
        }
    }
}
