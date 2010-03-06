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

    //import org.coderepos.net.pop.transaction.POPRetrievalTransaction;
    //import org.coderepos.net.pop.transaction.POPAuthOnlyTransaction;

    public class POPResponseBufferTest extends TestCase
    {
        public function POPResponseBufferTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new POPResponseBufferTest("testBuffer"));
            ts.addTest(new POPResponseBufferTest("testBuffer2"));
            ts.addTest(new POPResponseBufferTest("testBuffer3"));
            ts.addTest(new POPResponseBufferTest("testMultipleLineBuffer"));
            ts.addTest(new POPResponseBufferTest("testMultipleLineBuffer2"));
            ts.addTest(new POPResponseBufferTest("testMultipleLineBuffer3"));
            return ts;
        }

        public function testMultipleLineBuffer():void
        {
            //var c:POPConfig = new POPConfig();
            //var t1:POPRetrievalTransaction = new POPRetrievalTransaction(c);
            //var t2:POPAuthOnlyTransaction = new POPAuthOnlyTransaction(c);
            var buffer:POPMultipleLineResponseBuffer = new POPMultipleLineResponseBuffer();
            buffer.pushBytes(stringToBytes("+OK\r\n"));
            assertFalse('not finished yet', buffer.isFinished);
            buffer.pushBytes(stringToBytes("1 764\r\n"));
            buffer.pushBytes(stringToBytes("2 876\r\n"));
            buffer.pushBytes(stringToBytes("3 234\r\n"));
            buffer.pushBytes(stringToBytes("4 345\r\n"));
            assertFalse('not finished yet', buffer.isFinished);
            buffer.pushBytes(stringToBytes(".\r\n"));
            assertTrue('completed', buffer.isFinished);
            var res:POPResponse = buffer.response;
            assertFalse('not error', res.isError);
            assertEquals('data is ok', "1 764\r\n2 876\r\n3 234\r\n4 345", res.data);

            //assertEquals("value", "+OK\r\n1 764\r\n2 876\r\n3 234\r\n4 345", res.valueOf());
            assertEquals("value", "+OK", res.valueOf());

            var bytes:ByteArray = res.data;
            bytes.position = 0;
            var result:String = bytes.readUTFBytes(bytes.length);
            assertEquals("value", "1 764\r\n2 876\r\n3 234\r\n4 345", result);
        }

        public function testMultipleLineBuffer2():void
        {
            var buffer:POPMultipleLineResponseBuffer = new POPMultipleLineResponseBuffer();
            buffer.pushBytes(stringToBytes("-ERR message foobar\r\n"));
            assertTrue('finished', buffer.isFinished);
            var res:POPResponse = buffer.response;
            assertTrue('is error', res.isError);
            assertEquals('status found', 'message foobar', res.status);

            assertEquals("value", "-ERR message foobar", res.valueOf());
        }

        public function testMultipleLineBuffer3():void
        {
            var buffer:POPMultipleLineResponseBuffer = new POPMultipleLineResponseBuffer();
            var errorOccured:Boolean = false;
            try {
                buffer.pushBytes(stringToBytes("UNKNOWN FORMAT\r\n"));
            } catch (e:POPResponseFormatError) {
                errorOccured = true;
            }
            assertTrue('unknown format', errorOccured);
        }

        public function testBuffer():void
        {
            var buffer:POPResponseBuffer = new POPResponseBuffer();
            buffer.pushBytes(stringToBytes("+OK"));
            assertFalse('not finished yet',buffer.isFinished);
            buffer.pushBytes(stringToBytes(" message \r\n"));
            assertTrue('completed', buffer.isFinished);

            var res:POPResponse = buffer.response;
            assertFalse('is not error', res.isError);
            assertEquals('status ok', 'message', res.status);

            assertEquals("value", "+OK message", res.valueOf());
        }

        public function testBuffer2():void
        {
            var buffer:POPResponseBuffer = new POPResponseBuffer();
            buffer.pushBytes(stringToBytes("-ERR"));
            assertFalse('not finished yet', buffer.isFinished);
            buffer.pushBytes(stringToBytes(" message \r\n"));
            assertTrue('finished', buffer.isFinished);

            var res:POPResponse = buffer.response;
            assertTrue('is error', res.isError);
            assertEquals('status ok', 'message', res.status);
            assertEquals("value", "-ERR message", res.valueOf());
        }

        public function testBuffer3():void
        {
            var buffer:POPResponseBuffer = new POPResponseBuffer();
            var result:Boolean = false;
            try {
                buffer.pushBytes(stringToBytes("UNKNOWN FORMAT\r\n"));
            } catch (e:POPResponseFormatError) {
                result = true;
            }

            assertTrue('unknown format raises error', result);
        }

        private function stringToBytes(s:String):ByteArray
        {
            var b:ByteArray = new ByteArray();
            b.writeUTFBytes(s);
            b.position = 0;
            return b;
        }
    }
}

