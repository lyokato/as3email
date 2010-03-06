package suite {
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.net.imap.parser.*;
    import org.coderepos.net.imap.data.*;

    public class IMAPResponseParserTest extends TestCase
    {
        public function IMAPResponseParserTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new IMAPResponseParserTest("testParseLiteral"));
            ts.addTest(new IMAPResponseParserTest("testParseUntagged"));
            ts.addTest(new IMAPResponseParserTest("testParseTagged"));
            ts.addTest(new IMAPResponseParserTest("testParseContinuation"));
            return ts;
        }

        public function testParseContinuation():void
        {
            var p:ResponseParser = new ResponseParser();
            var res1:* = p.parse("+ AmFYig==\r\n");
            assertNotNull(res1);
            assertEquals('ResponseText.text', 'AmFYig==', res1.data.text);
            assertNull(res1.data.code);
            assertEquals('rawData', "+ AmFYig==\r\n", res1.rawData);
        }

        public function testParseTagged():void
        {
            var p:ResponseParser = new ResponseParser();
            var res1:* = p.parse("1869 OK LIST completed\r\n");
            assertNotNull(res1);
            assertEquals('tag is correct', "1869", res1.tag);
            assertEquals('response name should be OK', 'OK', res1.name);
            assertEquals('rawData is correct', "1869 OK LIST completed\r\n", res1.rawData);
            assertEquals('ResponseText', 'LIST completed', res1.data.text);
            assertNull(res1.data.code);

            var res2:* = p.parse("006 OK [READ-ONLY] Ok\r\n");
            assertNotNull(res2);
            assertEquals('tag is correct', '006', res2.tag);
            assertEquals('response name should be OK', 'OK', res2.name);
            assertEquals('rawData is correct', "006 OK [READ-ONLY] Ok\r\n", res2.rawData);
            assertEquals('ResponseText', ' Ok', res2.data.text);
            assertNotNull(res2.data.code);
            assertEquals('ResponseCode.name', 'READ-ONLY', res2.data.code.name);
            assertNull(res2.data.code.data);

        }

        public function testParseUntagged():void
        {
            var p:ResponseParser = new ResponseParser();
            var res1:* = p.parse("* LIST (\\HasNoChildren \\Marked) \".\" \"INBOX.Sent\"\r\n");
            assertNotNull(res1);
            assertEquals('response name should be LIST', 'LIST', res1.name);
            assertEquals('rawData is correct', "* LIST (\\HasNoChildren \\Marked) \".\" \"INBOX.Sent\"\r\n", res1.rawData);
            var mailboxlist:MailboxList = res1.data as MailboxList;
            assertEquals('mailbox name', 'INBOX.Sent', mailboxlist.name);
            assertEquals('mailbox delimiter', '.', mailboxlist.delim);
            assertEquals('first attr of mailboxlist is HasNoChildren', 'HasNoChildren', mailboxlist.attr[0]);
            assertEquals('Second attr of mailboxlist is Marked', 'Marked', mailboxlist.attr[1]);

            var res2:* = p.parse("* OK [UIDVALIDITY 115471893] Ok\r\n");
            assertNotNull(res2);
            assertEquals('response name', 'OK', res2.name);
            assertEquals('ResponseText', ' Ok', res2.data.text);
            assertEquals('ResponseCode.name', 'UIDVALIDITY', res2.data.code.name);
            assertEquals('ResponseCode.data', '115471893',   res2.data.code.data);

            var res3:* = p.parse("* OK [MYRIGHTS \"acdilrsw\"] Ok\r\n");
            assertNotNull(res3);
            assertEquals('response name', 'OK', res3.name);
            assertEquals('ResponseText', ' Ok', res3.data.text);
            assertEquals('ResponseCode.name', 'MYRIGHTS', res3.data.code.name);
            assertEquals('ResponseCode.data', '"acdilrsw"',   res3.data.code.data);

            var res4:* = p.parse("* OK [PERMANENTFLAGS (\\* \\Draft \\Answered \\Flagged \\Deleted \\Seen)] Limited\r\n");
            assertNotNull(res4);
            assertEquals('response name', 'OK', res4.name);
            assertEquals('response text', ' Limited', res4.data.text);
            assertEquals('ResponseCode.name', 'PERMANENTFLAGS', res4.data.code.name);
            assertEquals('ResponseCode.data', '*:Draft:Answered:Flagged:Deleted:Seen', res4.data.code.data.join(':'));

            var res5:* = p.parse("* CAPABILITY IMAP4rev1 UIDPLUS CHILDREN NAMESPACE THREAD=ORDEREDSUBJECT THREAD=REFERENCES SORT QUOTA AUTH=CRAM-MD5 AUTH=CRAM-SHA1 AUTH=CRAM-SHA256 IDLE ACL ACL2=UNION STARTTLS\r\n");
            assertNotNull(res5);
            assertEquals('response name', 'CAPABILITY', res5.name);
            //assertEquals('response text', '', res5.data.text);
            assertEquals('data', 'IMAP4REV1:UIDPLUS:CHILDREN:NAMESPACE:THREAD=ORDEREDSUBJECT:THREAD=REFERENCES:SORT:QUOTA:AUTH=CRAM-MD5:AUTH=CRAM-SHA1:AUTH=CRAM-SHA256:IDLE:ACL:ACL2=UNION:STARTTLS', res5.data.join(':'));
        }

        public function testParseLiteral():void
        {
            // RFC2060 example
            var p:ResponseParser = new ResponseParser();
            var commandLine:String = "* 12 FETCH (BODY[HEADER] {350}\r\n"
            var bodyPart:String =
             "Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)\r\n"
            +"From: Terry Gray <gray@cac.washington.edu>\r\n"
            +"Subject: IMAP4rev1 WG mtg summary and minutes\r\n"
            +"To: imap@cac.washington.edu\r\n"
            +"cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>\r\n"
            +"Message-Id: <B27397-0100000@cac.washington.edu>\r\n"
            +"MIME-Version: 1.0\r\n"
            +"Content-Type: TEXT/PLAIN; CHARSET=US-ASCII\r\n\r\n";
            var endingPart:String = ")\r\n";
            assertEquals(bodyPart.length, 350);
            var res1:* = p.parse(commandLine + bodyPart + endingPart);
            assertNotNull(res1);
        }
    }
}
