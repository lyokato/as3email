package org.coderepos.net.pop.transaction
{
    import flash.utils.ByteArray;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.EventDispatcher;

    import com.adobe.utils.StringUtil;

    import org.coderepos.net.mime.MIMEMessage;
    import org.coderepos.net.mime.MIMEParser;
    import org.coderepos.net.mime.exceptions.MIMEFormatError;

    import org.coderepos.net.pop.POPConfig;
    import org.coderepos.net.pop.POPConnection;
    import org.coderepos.net.pop.POPResponse;

    import org.coderepos.net.pop.logger.IPOPLogger;

    import org.coderepos.net.pop.events.POPResponseEvent;
    import org.coderepos.net.pop.events.POPTransactionEvent;
    import org.coderepos.net.pop.events.POPMessageEvent;
    import org.coderepos.net.pop.events.POPErrorEvent;

    import org.coderepos.net.pop.commands.IPOPCommand;
    import org.coderepos.net.pop.commands.APOP;
    import org.coderepos.net.pop.commands.USER;
    import org.coderepos.net.pop.commands.PASS;
    import org.coderepos.net.pop.commands.LIST;
    import org.coderepos.net.pop.commands.UIDL;
    import org.coderepos.net.pop.commands.RETR;
    import org.coderepos.net.pop.commands.DELE;
    import org.coderepos.net.pop.commands.QUIT;

    import org.coderepos.net.pop.uidstore.IUIDStore;
    import org.coderepos.net.pop.uidstore.NullUIDStore;

    /*
        var config:POPConfig = new POPConfig();
        config.username = "foo";
        config.password = "bar";
        config.host     = "pop.example.org";
        config.port     = 110;

        var txn:POPRetrievalTransaction = new POPRetrievalTransaction(config);
        txn.addEventListener(Event.CONNECT, connectHandler);
        txn.addEventListener(Event.CLOSE, closeHandler);
        txn.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        txn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

        txn.addEventListener(POPErrorEvent.ERROR, errorHandler);
        txn.addEventListener(POPErrorEvent.TIMEOUT, timeoutHandler);
        txn.addEventListener(POPMessageEvent.RETRIEVED, retrievedMessageHandler);
        txn.addEventListener(POPMessageEvent.DELETED, deletedMessageHandler);
        txn.addEventListener(POPTransactionEvent.AUTHENTICATED, authenticatedHandler);
        txn.addEventListener(POPTransactionEvent.RETRIEVED, retrievedAllMessageHandler);
        txn.addEventListener(POPTransactionEvent.DELETED, deletedAllMessageHandler);
        txn.addEventListener(POPTransactionEvent.COMPLETED, completedHandler);

        txn.start();

        private function retrieve(e:POPMessageEvent):void
        {
            var msg:MIMEMessage = e.message
        }
    */

    public class POPRetrievalTransaction extends EventDispatcher implements IPOPTransaction
    {
        private var _config:POPConfig;
        private var _logger:IPOPLogger;
        private var _messageParser:MIMEParser;
        private var _connection:POPConnection;
        private var _uidStore:IUIDStore;

        private var _retrieveQueue:Array;
        private var _deleteQueue:Array;

        public function POPRetrievalTransaction(config:POPConfig, uidStore:IUIDStore=null, logger:IPOPLogger=null)
        {
            _config = config;
            _messageParser = new MIMEParser();
            _uidStore = (uidStore != null) ? uidStore : new NullUIDStore();
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

            _retrieveQueue = [];
            _deleteQueue   = [];
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

                _connection.addEventListener(POPResponseEvent.RECEIVED, uidlResponseHandler);
                _connection.sendCommand(new UIDL());
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
                _connection.addEventListener(POPResponseEvent.RECEIVED, passResponseHandler);
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

                _connection.addEventListener(POPResponseEvent.RECEIVED, uidlResponseHandler);
                _connection.sendCommand(new UIDL());
            }
        }

        private function uidlResponseHandler(e:POPResponseEvent):void
        {
            _connection.removeEventListener(POPResponseEvent.RECEIVED,
                uidlResponseHandler);

            var res:POPResponse = e.response;

            if (res.isError) {
                dispatchError(res.valueOf());
                cancel();
            } else {

                var data:ByteArray = res.data
                if (data != null && data.length > 0) {
                    data.position = 0;
                    var dataStr:String = data.readUTFBytes(data.length);
                    var lines:Array = dataStr.split(/\r\n/);
                    var len:int = lines.length;

                    var now:int = (new Date()).time;

                    for (var i:int = 0; i < len; i++) {

                        var line:String = lines[i];
                        var matched:Array = line.match(/^\s*(\d+)\s+([^\s]+)\s*$/);

                        if (matched != null) {

                            var id:String  = matched[1];
                            var uid:String = matched[2];

                            if (!_uidStore.hasUID(uid)) {
                                // don't have this message, let's retrieve.
                                _retrieveQueue.push(new RETR(id, uid));

                                if (!_config.storeOnServer)
                                    _deleteQueue.push(new DELE(id, uid));

                            } else {
                                var t:Number = _uidStore.retrieveUIDTime(uid);
                                if ( (!_config.storeOnServer)      // delete all message?
                                || (   _config.expiration != 0     // has expiration?
                                    && (t + _config.expiration) < now ) // expired?
                                ) {
                                    // already have this message
                                    // and it is expired, so, let's delete.
                                    _deleteQueue.push(new DELE(id, uid));
                                }
                            }
                        }
                    }
                }
                _connection.addEventListener(POPResponseEvent.RECEIVED, retrResponseHandler);
                retrieveNext();
            }
        }

        private function retrieveNext():void
        {
            if (_retrieveQueue.length > 0) {
                var command:IPOPCommand = _retrieveQueue.shift();
                _connection.sendCommand(command);
            } else {
                _connection.removeEventListener(POPResponseEvent.RECEIVED, retrResponseHandler);

                dispatchEvent(new POPTransactionEvent(POPTransactionEvent.RETRIEVED));

                _connection.addEventListener(POPResponseEvent.RECEIVED, deleResponseHandler);
                deleteNext();
            }
        }

        private function retrResponseHandler(e:POPResponseEvent):void
        {
            var res:POPResponse = e.response;

            if (res.isError) {

                // dispatch error and disconnect
                // XXX: should continue to retrieve messages?
                _connection.removeEventListener(POPResponseEvent.RECEIVED, retrResponseHandler);
                dispatchError(res.valueOf());
                cancel();

            } else {
                if (res.targetUID != null)
                    _uidStore.storeUID(res.targetUID);

                var message:MIMEMessage;
                try {
                    message = _messageParser.parse(res.data);
                } catch (err:*) {
                    if (err is MIMEFormatError) {
                        _logger.logFormatError(err.message);
                    } else {
                        throw err;
                    }
                }
                if (message != null)
                    dispatchEvent(new POPMessageEvent(POPMessageEvent.RETRIEVED, message));
                retrieveNext();
            }
        }

        private function deleteNext():void
        {
            if (_deleteQueue.length > 0) {
                var command:IPOPCommand = _deleteQueue.shift();
                _connection.sendCommand(command);
            } else {
                // complete
                _connection.removeEventListener(POPResponseEvent.RECEIVED,
                    deleResponseHandler);

                dispatchEvent(new POPTransactionEvent(POPTransactionEvent.DELETED));

                _connection.addEventListener(POPResponseEvent.RECEIVED,
                    quitResponseHandler);
                _connection.sendCommand(new QUIT());
            }
        }

        private function deleResponseHandler(e:POPResponseEvent):void
        {
            var res:POPResponse = e.response;

            if (res.isError) {

                // dispatch error and disconnect
                // XXX: should continue to delete messages?
                _connection.removeEventListener(POPResponseEvent.RECEIVED,
                    deleResponseHandler);

                dispatchError(res.valueOf());
                cancel();

            } else {
                if (res.targetUID != null)
                    _uidStore.removeUID(res.targetUID);

                dispatchEvent(new POPMessageEvent(POPMessageEvent.DELETED));
                deleteNext();
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
                timeoutHandler);
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

