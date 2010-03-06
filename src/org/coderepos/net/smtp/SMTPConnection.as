package org.coderepos.net.smtp
{
    import flash.utils.Timer;
    import flash.utils.ByteArray;
    import flash.net.Socket;
    import flash.events.EventDispatcher;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.ProgressEvent;

    import com.hurlant.crypto.tls.TLSSocket;

    import org.coderepos.net.smtp.events.SMTPResponseEvent;
    import org.coderepos.net.smtp.events.SMTPErrorEvent;

    import org.coderepos.net.smtp.logger.ISMTPLogger;
    import org.coderepos.net.smtp.logger.SMTPNullLogger;

    import org.coderepos.net.smtp.commands.ISMTPCommand;

    import org.coderepos.net.smtp.exceptions.SMTPResponseFormatError;

    public class SMTPConnection extends EventDispatcher
    {
        private var _socket:*; // Socket|TLSSocket
        private var _logger:ISMTPLogger;
        private var _buffer:SMTPResponseBuffer;
        private var _isRequesting:Boolean;
        private var _timer:Timer;

        public function SMTPConnection(timeout:uint = 5000)
        {
            _isRequesting = false;
            _timer = new Timer(timeout);
            _timer.addEventListener(TimerEvent.TIMER, timeoutHandler);
            _logger = new SMTPNullLogger();
            _buffer = new SMTPResponseBuffer();
        }

        public function set logger(logger:ISMTPLogger):void
        {
            _logger = logger;
        }

        public function dispose():void
        {
            releaseSocket();
            _isRequesting = false;
            _timer.reset();
            _buffer.reset();
        }

        private function releaseSocket():void
        {
            _socket.removeEventListener(Event.CONNECT, dispatchEvent);
            _socket.removeEventListener(Event.CLOSE, closeHandler);
            _socket.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _socket.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
            _socket = null;
        }

        public function get connected():Boolean
        {
            return (_socket != null && _socket.connected);
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
            _socket.connect(host, port);
        }

        public function disconnect():void
        {
            if (_socket != null && _socket.connected)
                _socket.close();
            dispose();
        }

        private function createTLSSocket():TLSSocket
        {
            return new TLSSocket();
        }

        private function createSocket():Socket
        {
            return new Socket();
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

        private function timeoutHandler(e:TimerEvent):void
        {
            //_timer = null;
            dispose();
            dispatchEvent(new SMTPErrorEvent(SMTPErrorEvent.TIMEOUT, "timeout"));
        }

        // XXX: I know this is bad design. shoud make ISMTPContinuationCommand
        public function sendData(bytes:ByteArray):void
        {
            if (!(_socket != null && _socket.connected))
                throw new Error("socket not connected.");

            if (_isRequesting)
                throw new Error("is still requesting last command.");

            _buffer.reset();

            bytes.position = 0;
            _logger.logRequest(bytes.readUTFBytes(bytes.length));
            bytes.position = 0;

            _socket.writeBytes(bytes);
            _socket.flush();
            _timer.start();
        }

        public function sendCommand(command:ISMTPCommand):void
        {
            if (!(_socket != null && _socket.connected))
                throw new Error("socket not connected.");

            if (_isRequesting)
                throw new Error("is still requesting last command.");

            _buffer.reset();
            _logger.logRequest(command.valueOf());
            _socket.writeBytes(command.toByteArray());
            _socket.flush();
            _timer.start();
        }

        private function socketDataHandler(e:ProgressEvent):void
        {
            try {
                while (_socket != null && _socket.connected
                    && _socket.bytesAvailable > 0) {
                    var b:ByteArray = new ByteArray();
                    _socket.readBytes(b, 0, _socket.bytesAvailable);
                    b.position = 0;
                    _buffer.pushBytes(b);
                }
            } catch (e:*) {
                if (e is SMTPResponseFormatError) {
                    dispatchEvent(new SMTPErrorEvent(SMTPErrorEvent.ERROR, e.message));
                    disconnect();
                } else {
                    throw e;
                }
            }

            if (_buffer.isFinished) {
                _timer.reset();
                var res:SMTPResponse = _buffer.response;
                _logger.logResponse(res.valueOf());
                dispatchEvent(new SMTPResponseEvent(SMTPResponseEvent.RECEIVED, res));
            }
        }
    }
}

