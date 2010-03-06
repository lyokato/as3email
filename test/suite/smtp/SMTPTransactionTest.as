package suite.smtp
{
    import flash.utils.ByteArray;
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.net.smtp.SMTPConfig;
    import org.coderepos.net.smtp.transaction.SMTPTransaction;

    public class SMTPTransactionTest extends TestCase
    {
        public function SMTPTransactionTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new SMTPTransactionTest("testLoad"));
            return ts;
        }

        public function testLoad():void
        {
            var c:SMTPConfig = new SMTPConfig;
            var t:SMTPTransaction = new SMTPTransaction(c);
            assertEquals('loaded','loaded');
        }

    }
}
