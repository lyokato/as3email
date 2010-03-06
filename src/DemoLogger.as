package
{
    import org.coderepos.net.pop.logger.IPOPLogger;
    import org.coderepos.net.smtp.logger.ISMTPLogger;
    import org.coderepos.net.mime.MIMEUtil;

    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    public class DemoLogger implements IPOPLogger, ISMTPLogger
    {
        private var _log:DemoLog;

        public function DemoLogger(log:DemoLog)
        {
            _log = log;
        }

        public function logLine(line:String):void
        {
            _log.append(line + "\n");
        }

        public function logRequest(req:String):void
        {
            _log.append(req);
        }

        public function logResponse(res:String):void
        {
            _log.append(res);
        }

        public function logFormatError(res:String):void
        {
            var id:String = MIMEUtil.genRandom(10);
            var path:File = File.applicationStorageDirectory.resolvePath(id + ".txt");
            trace(path);
            var stream:FileStream = new FileStream();
            stream.open(path, FileMode.WRITE);
            stream.writeUTFBytes(res);
            stream.close();
        }
    }
}

