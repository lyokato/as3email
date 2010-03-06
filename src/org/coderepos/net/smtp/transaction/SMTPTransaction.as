package org.coderepos.net.smtp.transaction
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.EventDispatcher;
    import flash.utils.ByteArray;

    import com.adobe.utils.StringUtil;
    import com.hurlant.util.Base64;

    import org.coderepos.sasl.SASLMechanismDefaultFactory;
    import org.coderepos.sasl.SASLMechanismFactory;
    import org.coderepos.sasl.mechanisms.ISASLMechanism;

    import org.coderepos.net.mime.MIMEMessage;
    import org.coderepos.net.mime.MIMEFormatter;
    import org.coderepos.net.mime.MIMEMailAddress;

    import org.coderepos.net.smtp.SMTPConfig;
    import org.coderepos.net.smtp.SMTPConnection;
    import org.coderepos.net.smtp.SMTPResponse;

    import org.coderepos.net.smtp.events.SMTPResponseEvent;
    import org.coderepos.net.smtp.events.SMTPTransactionEvent;
    import org.coderepos.net.smtp.events.SMTPErrorEvent;

    import org.coderepos.net.smtp.logger.ISMTPLogger;

    import org.coderepos.net.smtp.commands.ISMTPCommand;
    import org.coderepos.net.smtp.commands.HELO;
    import org.coderepos.net.smtp.commands.EHLO;
    import org.coderepos.net.smtp.commands.AUTH;
    import org.coderepos.net.smtp.commands.MAIL;
    import org.coderepos.net.smtp.commands.RCPT;
    import org.coderepos.net.smtp.commands.DATA;
    import org.coderepos.net.smtp.commands.QUIT;

    public class SMTPTransaction extends EventDispatcher
    {
        private var _connection:SMTPConnection;
        private var _config:SMTPConfig;

        private var _message:MIMEMessage;
        private var _recipients:Array;
        private var _from:MIMEMailAddress;

        private var _saslFactory:SASLMechanismFactory;
        private var _saslMech:ISASLMechanism;

        private var _formatter:MIMEFormatter;
        private var _isRunning:Boolean;
        private var _logger:ISMTPLogger;

        public function SMTPTransaction(config:SMTPConfig,
            logger:ISMTPLogger=null)
        {
            _formatter = new MIMEFormatter();
            _config    = config;
            _logger    = logger;
        }

        public function start(message:MIMEMessage):void
        {
            if (_isRunning)
                throw new Error("transaction is running.");

            _isRunning = true;

            _message    = message;
            _recipients = message.getAllRecipients();
            _from       = message.from;

            if (_recipients.length == 0)
                throw new Error("No recipient found");

            if (_from == null)
                throw new Error("From address is empty.");

            _saslMech = null;
            if (_config.useSMTPAuth) {
                _saslFactory =
                    new SASLMechanismDefaultFactory(_config.username, _config.password);
            }

            _connection = new SMTPConnection(_config.timeout);
            if (_logger != null)
                _connection.logger = _logger;
            _connection.addEventListener(Event.CONNECT, dispatchEvent);
            _connection.addEventListener(Event.CLOSE, closeHandler);
            _connection.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

            _connection.addEventListener(SMTPResponseEvent.RECEIVED, openHandler);
            _connection.addEventListener(SMTPErrorEvent.TIMEOUT, dispatchEvent);
            _connection.addEventListener(SMTPErrorEvent.ERROR, dispatchEvent);

            _connection.connect(_config.host, _config.port, _config.overTLS);
        }

        private function dispose():void
        {
            _isRunning   = false;

            _message    = null;
            _recipients = [];
            _from       = null;

            _saslFactory = null;
            _saslMech    = null;
        }

        private function closeHandler(e:Event):void
        {
            dispose();
            dispatchEvent(e);
        }

        private function ioErrorHandler(e:IOErrorEvent):void
        {
            dispose();
            dispatchEvent(e);
        }

        private function securityErrorHandler(e:SecurityErrorEvent):void
        {
            dispose();
            dispatchEvent(e);
        }

        public function cancel():void
        {
            if (_connection != null)
                _connection.disconnect();
        }

        private function dispatchError(message:String):void
        {
            dispatchEvent(new SMTPErrorEvent(SMTPErrorEvent.ERROR, message));
        }

        private function openHandler(e:SMTPResponseEvent):void
        {
            _connection.removeEventListener(SMTPResponseEvent.RECEIVED, openHandler);

            var res:SMTPResponse = e.response;
            if (res.isError) {
                dispatchError(res.valueOf());
                cancel();
            } else {
                // if server supports ESMTP, send EHLO, otherwise, send HELO.
                var lines:Array = res.lines;
                var len:int = lines.length;
                var isESMTP:Boolean = false;
                for (var i:int = 0; i < len; i++) {
                    var matched:Array = lines[i].match(/ESMTP/i);
                    if (matched != null)
                        isESMTP = true;
                }
                if (isESMTP) {
                    _connection.addEventListener(SMTPResponseEvent.RECEIVED, ehloHandler);
                    _connection.sendCommand(new EHLO(_config.localAddress));
                } else {
                    _connection.addEventListener(SMTPResponseEvent.RECEIVED, heloHandler);
                    _connection.sendCommand(new HELO(_config.localAddress));
                }
            }
        }

        private function heloHandler(e:SMTPResponseEvent):void
        {
            _connection.removeEventListener(SMTPResponseEvent.RECEIVED,
                heloHandler);

            var res:SMTPResponse = e.response;
            if (res.isError) {
                dispatchError(res.valueOf());
                cancel();
            } else {

                _connection.addEventListener(SMTPResponseEvent.RECEIVED, mailHandler);
                _connection.sendCommand(new MAIL(_from));

            }
        }

        private function ehloHandler(e:SMTPResponseEvent):void
        {
            _connection.removeEventListener(SMTPResponseEvent.RECEIVED,
                ehloHandler);

            var res:SMTPResponse = e.response;
            if (res.isError) {

                dispatchError(res.valueOf());
                cancel();
            } else {

                // in case that useSMTPAuth-flag is on,
                // and server supports AUTH extension,
                // and our factory supports one of the sasl-mechanisms server
                // supports.
                // then try AUTH

                if (_config.useSMTPAuth) {
                    var lines:Array = res.lines;
                    var len:int = lines.length;
                    var mechs:Array = [];
                    for (var i:int = 0; i < len; i++) {
                        var matched:Array = lines[i].match(/^AUTH\s+(.+)$/i);
                        if (matched != null) {
                            mechs = StringUtil.rtrim(matched[1]).split(/\s+/);
                        }
                    }
                    len = mechs.length;
                    for (i = 0; i < len; i++) {
                        _saslMech = _saslFactory.getMechanism(mechs[i].toUpperCase());
                        if (_saslMech != null)
                            break;
                    }
                    if (_saslMech != null) {
                        var start:String = _saslMech.start();
                        if (start != null && start.length > 0)
                            start = Base64.encode(start);
                        _connection.addEventListener(SMTPResponseEvent.RECEIVED, authHandler);
                        _connection.sendCommand(new AUTH(_saslMech.name, start));
                    } else {
                        _connection.addEventListener(SMTPResponseEvent.RECEIVED, mailHandler);
                        _connection.sendCommand(new MAIL(_from));
                    }
                } else {
                    _connection.addEventListener(SMTPResponseEvent.RECEIVED, mailHandler);
                    _connection.sendCommand(new MAIL(_from));
                }
            }
        }

        private function authHandler(e:SMTPResponseEvent):void
        {
            var res:SMTPResponse = e.response;

            if (res.isError) {

                _connection.removeEventListener(SMTPResponseEvent.RECEIVED,
                    authHandler);

                dispatchError(res.valueOf());
                cancel();

            } else if (e.response.code == 334) { // continuation

                var challenge:String = Base64.decode(res.lines[0]);
                var step:String = Base64.encode(_saslMech.step(challenge)) + "\r\n";
                var stepBytes:ByteArray = new ByteArray();
                stepBytes.writeUTFBytes(step);
                stepBytes.position = 0;
                _connection.sendData(stepBytes);

            } else { // success

                _connection.removeEventListener(SMTPResponseEvent.RECEIVED,
                    authHandler);

                _connection.addEventListener(SMTPResponseEvent.RECEIVED, mailHandler);
                _connection.sendCommand(new MAIL(_from));

            }
        }

        private function mailHandler(e:SMTPResponseEvent):void
        {
            _connection.removeEventListener(SMTPResponseEvent.RECEIVED,
                mailHandler);

            var res:SMTPResponse = e.response;
            if (res.isError) {
                dispatchError(res.valueOf());
                cancel();
            } else {
                _connection.addEventListener(SMTPResponseEvent.RECEIVED, rcptHandler);
                sendNextRCPT();
            }
        }

        private function sendNextRCPT():void
        {
            if (_recipients.length > 0) {
                var recipient:MIMEMailAddress = _recipients.shift();
                _connection.sendCommand(new RCPT(recipient));
            } else {
                _connection.removeEventListener(SMTPResponseEvent.RECEIVED, rcptHandler);
                _connection.addEventListener(SMTPResponseEvent.RECEIVED, dataHandler);
                _connection.sendCommand(new DATA());
            }
        }

        private function rcptHandler(e:SMTPResponseEvent):void
        {
            var res:SMTPResponse = e.response;
            if (res.isError) {
                _connection.removeEventListener(SMTPResponseEvent.RECEIVED, rcptHandler);
                dispatchError(res.valueOf());
                cancel();
            } else {
                sendNextRCPT();
            }
        }

        private function dataHandler(e:SMTPResponseEvent):void
        {
            _connection.removeEventListener(SMTPResponseEvent.RECEIVED,
                dataHandler);

            var res:SMTPResponse = e.response;
            if (res.isError) {
                dispatchError(res.valueOf());
                cancel();
            } else {
                _connection.addEventListener(SMTPResponseEvent.RECEIVED, dataCompletedHandler);
                _connection.sendData(_formatter.formatToBytes(_message));
            }
        }

        private function dataCompletedHandler(e:SMTPResponseEvent):void
        {
            _connection.removeEventListener(SMTPResponseEvent.RECEIVED,
                dataCompletedHandler);

            var res:SMTPResponse = e.response;

            if (res.isError) {
                dispatchError(res.valueOf());
                cancel();
            } else {
                _connection.addEventListener(SMTPResponseEvent.RECEIVED, quitHandler);
                _connection.sendCommand(new QUIT());
            }
        }

        private function quitHandler(e:SMTPResponseEvent):void
        {
            _connection.removeEventListener(SMTPResponseEvent.RECEIVED,
                quitHandler);

            var res:SMTPResponse = e.response;

            if (res.isError) {
                dispatchError(res.valueOf());
                cancel();
            } else {
                dispatchEvent(new SMTPTransactionEvent(SMTPTransactionEvent.COMPLETED));
                _connection.disconnect();
            }
        }
    }
}

