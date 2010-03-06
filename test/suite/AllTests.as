package suite {
  import flexunit.framework.TestSuite;

  import suite.mime.*;
  import suite.imap.*;
  import suite.pop.*;
  import suite.smtp.*;

  public class AllTests extends TestSuite {
    public function AllTests() {
      super();
      // Add tests here
      // For examples, see: http://code.google.com/p/as3flexunitlib/wiki/Resources

      // test for classes under mime namespace
      //addTest(MiscTest.suite());
      addTest(QuotedPrintableTest.suite());
      addTest(ByteSequenceEncoderTest.suite());
      addTest(MediaTypeParserTest.suite());
      addTest(MIMEMailAddressTest.suite());
      addTest(MIMEFormatterTest.suite());
      //addTest(MIMEParserTest.suite());

      // test for classes under pop namespace
      addTest(POPResponseBufferTest.suite());
      addTest(POPTransactionTest.suite());

      // test for classes under smtp namespace
      addTest(SMTPResponseBufferTest.suite());
      addTest(SMTPTransactionTest.suite());

      // test for classes under imap namespace
      addTest(IMAPUTF7EncoderTest.suite());
      addTest(IMAPTagGeneratorTest.suite());
      //addTest(IMAPFlagParserTest.suite());
      //addTest(IMAPResponseBufferTest.suite());
    }
  }
}

