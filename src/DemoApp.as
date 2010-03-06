package
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.display.NativeWindow;
    import flash.desktop.NativeApplication;

    import mx.collections.ArrayCollection;

    import org.coderepos.net.mime.MIMEMessage;
    import org.coderepos.net.mime.MIMEMailAddress;

    import org.coderepos.net.smtp.SMTPConfig;
    import org.coderepos.net.smtp.transaction.SMTPTransaction;
    import org.coderepos.net.smtp.events.SMTPErrorEvent;
    import org.coderepos.net.smtp.events.SMTPTransactionEvent;

    import org.coderepos.net.pop.POPConfig;
    import org.coderepos.net.pop.transaction.IPOPTransaction;
    import org.coderepos.net.pop.transaction.POPRetrievalTransaction;
    import org.coderepos.net.pop.transaction.POPAuthOnlyTransaction;
    import org.coderepos.net.pop.uidstore.IUIDStore;
    import org.coderepos.net.pop.uidstore.OnMemoryUIDStore;
    import org.coderepos.net.pop.events.POPErrorEvent;
    import org.coderepos.net.pop.events.POPTransactionEvent;
    import org.coderepos.net.pop.events.POPMessageEvent;

    import org.coderepos.net.pop.POPConfig;

    public class DemoApp extends EventDispatcher
    {
        private static var _app:DemoApp;

        public static function get app():DemoApp
        {
            if (_app == null)
                _app = new DemoApp();
            return _app;
        }

        private var _settingWindow:DemoSettingWindow;
        private var _sendWindow:DemoSendWindow;
        private var _logWindow:DemoLogWindow;
        private var _logger:DemoLogger;
        private var _log:DemoLog;
        private var _rootWindow:DemoMUA;

        private var _setting:DemoSetting;
        private var _smtpTransaction:SMTPTransaction;
        private var _popTransaction:IPOPTransaction;
        private var _popUIDStore:IUIDStore;
        private var _isBusy:Boolean;
        [Bindable]
        public var messages:ArrayCollection;

        public function DemoApp()
        {
            _setting     = DemoSetting.load();
            _log         = new DemoLog();
            _logger      = new DemoLogger(_log);
            _popUIDStore = new OnMemoryUIDStore();
            _isBusy      = false;
            messages     = new ArrayCollection();
        }

        public function set rootWindow(win:DemoMUA):void
        {
            _rootWindow = win;
            _rootWindow.addEventListener(Event.CLOSING, shutDown);
        }

        private function shutDown(e:Event):void
        {
            saveSettings();
            closeAllWindows();
        }

        private function saveSettings():void
        {
            _setting.save();
        }

        private function closeAllWindows():void
        {
            var openedWindows:Array =
                NativeApplication.nativeApplication.openedWindows;
            for (var i:int = openedWindows.length - 1; i >= 0; --i) {
                var win:NativeWindow = openedWindows[i] as NativeWindow;
                win.close();
            }
        }

        public function openLogWindow():void
        {
            if (_logWindow == null || _logWindow.closed) {
                _logWindow = new DemoLogWindow();
                _logWindow.open();
                _logWindow.log = _log;
            }
            _logWindow.activate();
        }

        public function openSettingWindow():void
        {
            if (_settingWindow == null || _settingWindow.closed) {
                _settingWindow = new DemoSettingWindow();
                _settingWindow.open();
                _settingWindow.setting = _setting;
            }
            _settingWindow.activate();
        }

        public function openSendWindow():void
        {
            if (_sendWindow == null || _sendWindow.closed) {
                _sendWindow = new DemoSendWindow();
                _sendWindow.open();
            }
            _sendWindow.activate();
        }

        public function sendMessage(message:MIMEMessage):void
        {
            if (_isBusy)
                return;

            _sendWindow.close();

            var smtpConfig:SMTPConfig = _setting.genSMTPConfig();
            _smtpTransaction = new SMTPTransaction(smtpConfig, _logger);

            _smtpTransaction.addEventListener(Event.CONNECT, connectHandler);
            _smtpTransaction.addEventListener(Event.CLOSE, closeHandler);
            _smtpTransaction.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _smtpTransaction.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

            _smtpTransaction.addEventListener(SMTPErrorEvent.TIMEOUT, smtpTimeoutHandler);
            _smtpTransaction.addEventListener(SMTPErrorEvent.ERROR, smtpErrorHandler);
            _smtpTransaction.addEventListener(SMTPTransactionEvent.COMPLETED, smtpCompleteHandler);

            message.from = new MIMEMailAddress(_setting.from_address);
            _isBusy = true;
            _smtpTransaction.start(message);
        }

        public function receiveMessages():void
        {
            if (_isBusy) {
                throw new Error("isBusy");
                return;
            }

            var popConfig:POPConfig = _setting.genPOPConfig();
            popConfig.timeout = 40 * 1000;
            _popTransaction = new POPRetrievalTransaction(popConfig, _popUIDStore, _logger);

            _popTransaction.addEventListener(Event.CONNECT, connectHandler);
            _popTransaction.addEventListener(Event.CLOSE, closeHandler);
            _popTransaction.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _popTransaction.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

            _popTransaction.addEventListener(POPErrorEvent.TIMEOUT, popTimeoutHandler);
            _popTransaction.addEventListener(POPErrorEvent.ERROR, popErrorHandler);
            _popTransaction.addEventListener(POPMessageEvent.RETRIEVED, popMessageRetrievedHandler);
            //_popTransaction.addEventListener(POPMessageEvent.DELETED, popMessageDeletedHandler);
            //_popTransaction.addEventListener(POPTransactionEvent.AUTHENTICATED, popTransactionAuthenticatedHandler);
            //_popTransaction.addEventListener(POPTransactionEvent.RETRIEVED, popTransactionRetrievedHandler);
            //_popTransaction.addEventListener(POPTransactionEvent.DELETED, popTransactionDeletedHandler);
            _popTransaction.addEventListener(POPTransactionEvent.COMPLETED, popTransactionCompletedHandler);

            _isBusy = true;
            _popTransaction.start();
        }

        private function popMessageRetrievedHandler(e:POPMessageEvent):void
        {
            messages.addItem(e.message);
        }

        private function popTransactionCompletedHandler(e:POPTransactionEvent):void
        {
            _logger.logLine("[POP_COMPLETED]");
            _isBusy = false;
        }

        private function connectHandler(e:Event):void
        {
            _logger.logLine("[CONNECTED]");
        }

        private function closeHandler(e:Event):void
        {
            _isBusy = false;
            _logger.logLine("[CLOSED]");
        }

        private function ioErrorHandler(e:IOErrorEvent):void
        {
            _isBusy = false;
            _logger.logLine("[IO_ERROR] " + e.toString());
        }

        private function securityErrorHandler(e:SecurityErrorEvent):void
        {
            _isBusy = false;
            _logger.logLine("[SECURITY_ERROR] " + e.toString());
        }

        private function popTimeoutHandler(e:POPErrorEvent):void
        {
            _isBusy = false;
            _logger.logLine("[POP_TIMEOUT] " + e.message);
        }

        private function smtpTimeoutHandler(e:SMTPErrorEvent):void
        {
            _isBusy = false;
            _logger.logLine("[SMTP_TIMEOUT] " + e.message);
        }

        private function popErrorHandler(e:POPErrorEvent):void
        {
            _isBusy = false;
            _logger.logLine("[POP_ERROR] " + e.message);
        }

        private function smtpErrorHandler(e:SMTPErrorEvent):void
        {
            _isBusy = false;
            _logger.logLine("[SMTP_ERROR] " + e.message);
        }

        private function smtpCompleteHandler(e:SMTPTransactionEvent):void
        {
            _isBusy = false;
            _logger.logLine("[SMTP_COMPLETE]");
        }
    }
}

