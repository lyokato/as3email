package suite {
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;
    import flash.utils.ByteArray;

    import org.coderepos.net.imap.ResponseBuffer;
    import org.coderepos.net.imap.IMAPUtil;
    import org.coderepos.net.imap.parser.ResponseParser;
    import org.coderepos.net.imap.events.IMAPResponseEvent;
    import org.coderepos.net.imap.events.IMAPErrorEvent;
    import org.coderepos.net.imap.data.TaggedResponse;
    import org.coderepos.net.imap.data.UntaggedResponse;
    import org.coderepos.net.imap.data.ContinuationRequest;

    public class IMAPResponseBufferTest extends TestCase
    {
        public function IMAPResponseBufferTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new IMAPResponseBufferTest("testBuffer"));
            ts.addTest(new IMAPResponseBufferTest("testLiteralBuffer"));
            return ts;
        }

        public function testBuffer():void
        {
            var buffer:ResponseBuffer = new ResponseBuffer(new ResponseParser());
            buffer.addEventListener(IMAPResponseEvent.RECEIVE, addAsync(onReceivedBuffer, 1000));
            //buffer.addEventListener(IMAPErrorEvent.PARSE_ERROR, addAsync(onErrorBuffer, 1000));
            buffer.writeBytes(IMAPUtil.stringToBytes("+ AmFYig==\r\n"));
        }

        public function onErrorBuffer(e:IMAPErrorEvent):void
        {
            assertEquals(e.message, '');
        }

        public function onReceivedBuffer(e:IMAPResponseEvent):void
        {
            var res1:* = e.data
            assertNotNull(res1);
            assertEquals('ResponseText.text', 'AmFYig==', res1.data.text);
            assertNull(res1.data.code);
            assertEquals('rawData', "+ AmFYig==\r\n", res1.rawData);
        }

        public function testLiteralBuffer():void
        {
            var buffer:ResponseBuffer = new ResponseBuffer(new ResponseParser());
            buffer.addEventListener(IMAPResponseEvent.RECEIVE, addAsync(onReceived, 1000));
            buffer.addEventListener(IMAPErrorEvent.PARSE_ERROR, addAsync(onParseError, 1000));
            var s:String = "* 12 FETCH (BODY[HEADER] {350}\r\n"
            +"Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)\r\n"
            +"From: Terry Gray <gray@cac.washington.edu>\r\n"
            +"Subject: IMAP4rev1 WG mtg summary and minutes\r\n"
            +"To: imap@cac.washington.edu\r\n"
            +"cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>\r\n"
            +"Message-Id: <B27397-0100000@cac.washington.edu>\r\n"
            +"MIME-Version: 1.0\r\n"
            +"Content-Type: TEXT/PLAIN; CHARSET=US-ASCII\r\n\r\n"
            +")\r\n"
            +"* OK [UIDVALIDITY 115471893] Ok\r\n";
            buffer.writeBytes(IMAPUtil.stringToBytes(s));
        }

        private function onParseError(e:IMAPErrorEvent):void
        {
            assertEquals('', e.message, '');
        }

        private function onReceived(e:IMAPResponseEvent):void
        {
            if (e.data is TaggedResponse) {
                assertEquals('', 'TaggedResponse');
            } else if (e.data is UntaggedResponse) {
                assertEquals('', 'UntaggedResponse');
            } else if (e.data is ContinuationRequest) {
                assertEquals('', 'ContinutationRequest');
            } else {
                assertEquals('', 'Unknown');
            }
        }
    }
}

