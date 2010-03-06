package suite.imap
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.net.imap.TagGenerator;

    public class IMAPTagGeneratorTest extends TestCase
    {
        public function IMAPTagGeneratorTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new IMAPTagGeneratorTest("testGenerate"));
            return ts;
        }

        public function testGenerate():void
        {
            var generator:TagGenerator = new TagGenerator('hoge', 4);
            var tag:String = generator.generate();
            assertEquals('hoge0001', tag);
            tag = generator.generate();
            assertEquals('hoge0002', tag);
            tag = generator.generate();
            assertEquals('hoge0003', tag);
            var i:int = 10000;
            while (i > 0) {
                generator.generate();
                i--;
            }
            tag = generator.generate();
            assertEquals('hoge0004', tag);
        }
    }
}

