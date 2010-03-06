package org.coderepos.net.pop.transaction
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.EventDispatcher;

    import com.adobe.utils.StringUtil;

    import org.coderepos.net.pop.POPConfig;
    import org.coderepos.net.pop.POPConnection;
    import org.coderepos.net.pop.POPResponse;

    import org.coderepos.net.pop.logger.IPOPLogger;

    import org.coderepos.net.pop.events.POPTransactionEvent;
    import org.coderepos.net.pop.events.POPResponseEvent;
    import org.coderepos.net.pop.events.POPErrorEvent;

    import org.coderepos.net.pop.commands.APOP;
    import org.coderepos.net.pop.commands.USER;
    import org.coderepos.net.pop.commands.PASS;
    import org.coderepos.net.pop.commands.QUIT;

    // just for 'POP before SMTP'

    /*
        var config:POPConfig = new POPConfig();
        config.username = "foo";
        config.password = "bar";
        config.host = "pop.example.org";
        config.port = 110;

        var txn:POPAuthOnlyTransaction = new POPAuthOnlyTransaction(config);
        txn.addEventListener(Event.CONNECT, connectHandler);
        txn.addEventListener(Event.CLOSE, closeHandler);
        txn.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        txn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        txn.addEventListener(POPTransactionEvent.AUTHENTICATED, authenticatedHandler);
        txn.addEventListener(POPTransactionEvent.COMPLETED, completedHandler);
        txn.addEventListener(POPErrorEvent.ERROR, errorHandler);
        txn.addEventListener(POPErrorEvent.TIMEOUT, timeoutHandler);
        txn.start();

        private function completedHandler(e:POPTransactionEvent):void
        {
            startSMTPTransaction();
        }
    */

    public class POPAuthOnlyTransaction extends EventDispatcher implements IPOPTransaction
    {
        private var _config:POPConfig;
        private var _connection:POPConnection;
        private var _logger:IPOPLogger;

        public function POPAuthOnlyTransaction(config:POPConfig, logger:IPOPLogger=null)
        {
            _config = config;
            _logger = logger;
        }

        public function start():void
        {
            _connection = new POPConnection(_config.timeout);
            if (_logger != null)
                _connection.logger = _logger;
            _connection.addEventListener(Event.CONNECT, dispatchEvent);
            _connection.addEventListener(Event.CLOSE, dispatchEvent);
            _connection.addEventListener(IOErrorEvent.IO_ERROR, dispatchEvent);
            _connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchEvent);
            _connection.addEventListener(POPResponseEvent.RECEIVED, openHandler);
            _connection.addEventListener(POPErrorEvent.ERROR, errorHandler);
            _connection.addEventListener(POPErrorEvent.TIMEOUT, timeoutHandler);
            _connection.connect(_config.host, _config.port, _config.overTLS);
        }

        public function cancel():void
        {
            if (_connection != null)
                _connection.disconnect();
        }

        private function openHandler(e:POPResponseEvent):void
        {
            _connection.removeEventListener(POPResponseEvent.RECEIVED, openHandler);

            var res:POPResponse = e.response;

            if (res.isError) {
                dispatchError(res.valueOf());
                cancel();
            } else {
                var matched:Array = res.status.match(/\<([^>]+)\>/);
                if (matched != null && _config.useAPOP) {
                    var challenge:String = StringUtil.trim(matched[1]);
                    _connection.addEventListener(POPResponseEvent.RECEIVED, apopResponseHandler);
                    _connection.sendCommand(new APOP(challenge, _config.username, _config.password));
                } else {
                    _connection.addEventListener(POPResponseEvent.RECEIVED, userResponseHandler);
                    _connection.sendCommand(new USER(_config.username));
                }
            }
        }

        private function apopResponseHandler(e:POPResponseEvent):void
        {
            _connection.removeEventListener(POPResponseEvent.RECEIVED,
                apopResponseHandler);

            var res:POPResponse = e.response;

            if (res.isError) {
                dispatchError(res.valueOf());
                cancel();
            } else {
                dispatchEvent(new POPTransactionEvent(POPTransactionEvent.AUTHENTICATED));

                _connection.addEventListener(POPResponseEvent.RECEIVED, quitResponseHandler);
                _connection.sendCommand(new QUIT());
            }
        }

        private function userResponseHandler(e:POPResponseEvent):void
        {
            _connection.removeEventListener(POPResponseEvent.RECEIVED,
                userResponseHandler);

            var res:POPResponse = e.response;
            if (res.isError) {
                dispatchError(res.valueOf());
                cancel();
            } else {
                _connection.sendCommand(new PASS(_config.password));
            }
        }

        private function passResponseHandler(e:POPResponseEvent):void
        {
            _connection.removeEventListener(POPResponseEvent.RECEIVED,
                passResponseHandler);

            var res:POPResponse = e.response;
            if (res.isError) {
                dispatchError(res.valueOf());
                cancel();
            } else {
                dispatchEvent(new POPTransactionEvent(POPTransactionEvent.AUTHENTICATED));

                _connection.addEventListener(POPResponseEvent.RECEIVED, quitResponseHandler);
                _connection.sendCommand(new QUIT());
            }
        }

        private function quitResponseHandler(e:POPResponseEvent):void
        {
            _connection.removeEventListener(POPResponseEvent.RECEIVED,
                quitResponseHandler);

            var res:POPResponse = e.response;
            if (res.isError) {
                dispatchError(res.valueOf());
                cancel();
            } else {
                dispatchEvent(new POPTransactionEvent(POPTransactionEvent.COMPLETED));
                _connection.disconnect();
            }
        }

        private function dispatchError(message:String):void
        {
            dispatchEvent(new POPErrorEvent(POPErrorEvent.ERROR, message));
        }

        private function timeoutHandler(e:POPErrorEvent):void
        {
            _connection.removeEventListener(POPErrorEvent.TIMEOUT,
                errorHandler);
            dispatchEvent(e);
            _connection.disconnect();
        }

        private function errorHandler(e:POPErrorEvent):void
        {
            _connection.removeEventListener(POPErrorEvent.ERROR,
                errorHandler);
            dispatchEvent(e);
            _connection.disconnect();
        }
    }
}

