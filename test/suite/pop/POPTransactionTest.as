package suite.pop
{
    import flash.utils.ByteArray;
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.net.pop.POPConfig;
    import org.coderepos.net.pop.IPOPResponseBuffer;
    import org.coderepos.net.pop.POPResponseBuffer;
    import org.coderepos.net.pop.POPResponse;
    import org.coderepos.net.pop.POPMultipleLineResponseBuffer;
    import org.coderepos.net.pop.exceptions.POPResponseFormatError;

    import org.coderepos.net.pop.transaction.POPRetrievalTransaction;
    import org.coderepos.net.pop.transaction.POPAuthOnlyTransaction;

    public class POPTransactionTest extends TestCase
    {
        public function POPTransactionTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new POPTransactionTest("testLoad"));
            return ts;
        }

        public function testLoad():void
        {
            var c:POPConfig = new POPConfig();
            var t1:POPRetrievalTransaction = new POPRetrievalTransaction(c);
            var t2:POPAuthOnlyTransaction = new POPAuthOnlyTransaction(c);
            assertEquals('hoge', 'hoge');
        }

    }
}
