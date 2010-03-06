package org.coderepos.net.pop
{
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.net.Socket;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.ProgressEvent;

    import com.hurlant.crypto.tls.TLSSocket;

    import org.coderepos.net.pop.exceptions.POPResponseFormatError;
    import org.coderepos.net.pop.commands.IPOPCommand;
    import org.coderepos.net.pop.events.POPResponseEvent;
    import org.coderepos.net.pop.events.POPErrorEvent;
    import org.coderepos.net.pop.logger.IPOPLogger;
    import org.coderepos.net.pop.logger.POPNullLogger;

    public class POPConnection extends EventDispatcher
    {
        private var _socket:*; // Socket
        private var _buffer:IPOPResponseBuffer;
        private var _logger:IPOPLogger;
        private var _isRequesting:Boolean;
        private var _timer:Timer;
        private var _timeout:uint;

        public function POPConnection(timeout:uint=3600)
        {
            _buffer       = null;
            _isRequesting = false;
            _timeout      = timeout;
            _logger       = new POPNullLogger();

            _timer = new Timer(timeout);
            _timer.addEventListener(TimerEvent.TIMER, timeoutHandler);
        }

        public function set logger(logger:IPOPLogger):void
        {
            _logger = logger;
        }

        public function dispose():void
        {
            _buffer = null;
            _isRequesting = false;
            _timer.reset();
            releaseSocket();
        }

        public function get connected():Boolean
        {
            return (_socket != null && _socket.connected);
        }

        public function get isRequesting():Boolean
        {
            return _isRequesting;
        }

        public function connect(host:String, port:uint,
            overTLS:Boolean=false):void
        {
            _socket = (overTLS) ? createTLSSocket() : createSocket();
            _socket.addEventListener(Event.CONNECT, dispatchEvent);
            _socket.addEventListener(Event.CLOSE, closeHandler);
            _socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);

            _buffer = new POPResponseBuffer();
            _socket.connect(host, port);
        }

        private function releaseSocket():void
        {
            if (_socket == null)
                return;
            _socket.removeEventListener(Event.CONNECT, dispatchEvent);
            _socket.removeEventListener(Event.CLOSE, closeHandler);
            _socket.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _socket.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
            _socket == null;
        }

        public function disconnect():void
        {
            if (_socket != null && _socket.connected)
                _socket.close();
            dispose();
        }

        private function createSocket():Socket
        {
            return new Socket();
        }

        private function createTLSSocket():TLSSocket
        {
            return new TLSSocket();
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

        public function sendCommand(command:IPOPCommand):void
        {
            if (!(_socket != null && _socket.connected))
                throw new Error("socket not connected.");

            if (_isRequesting)
                throw new Error("is still requesting last command.");

            _buffer = command.supportsMultiLineResponse
                ? new POPMultipleLineResponseBuffer()
                : new POPResponseBuffer();

            if (command.targetID != null)
                _buffer.targetID = command.targetID;
            if (command.targetUID != null)
                _buffer.targetUID = command.targetUID;
            _logger.logRequest(command.valueOf());
            _socket.writeBytes(command.toByteArray());
            _socket.flush();
            _timer.start();
            _isRequesting = true;
        }

        private function timeoutHandler(e:TimerEvent):void
        {
            dispose();
            dispatchEvent(new POPErrorEvent(POPErrorEvent.TIMEOUT,
                "no response is received during " + String(_timeout) + "milli seconds"));
        }

        private function socketDataHandler(e:ProgressEvent):void
        {
            // XXX: throw error?
            if (_buffer == null)
                return;

            try {
                while (_socket != null && _socket.bytesAvailable > 0) {
                    var b:ByteArray = new ByteArray();
                    var len:uint = (1024 > _socket.bytesAvailable)
                        ? _socket.bytesAvailable : 1024;
                    _socket.readBytes(b, 0, len);
                    b.position = 0;
                    _buffer.pushBytes(b);
                }
            } catch (e:*) {
                if (e is POPResponseFormatError) {
                    _buffer = null;
                    dispatchEvent(new POPErrorEvent(POPErrorEvent.ERROR,
                        e.message));
                    disconnect();
                    return;
                } else {
                    throw e;
                }
            }

            if (_buffer.isFinished) {
                _timer.reset();
                _isRequesting = false;
                var res:POPResponse = _buffer.response;
                _buffer = null;
                _logger.logResponse(res.valueOf());
                dispatchEvent(new POPResponseEvent(POPResponseEvent.RECEIVED, res));
            }
        }
    }
}

