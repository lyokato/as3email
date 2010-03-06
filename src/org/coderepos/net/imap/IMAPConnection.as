package org.coderepos.net.imap
{

    import flash.net.Socket;
    import flash.utils.ByteArray;

    import org.coderepos.net.imap.events.IMAPResponseEvent;
    import org.coderepos.net.imap.events.IMAPErrorEvent;

    import org.coderepos.net.imap.data.TaggedResponse;
    import org.coderepos.net.imap.data.UntaggedResponse;
    import org.coderepos.net.imap.data.ContinuationRequest;

    public class IMAPConnection()
    {

        private var _socket:Socket;
        private var _buffer:ResponseBuffer;
        private var _lastResponse:IMAPResponse;
        private var _tagGenerator:TagGenerator;

        public function IMAPConnection()
        {
            _lastResponse = new IMAPResponse();
            _tagGenerator = new TagGenerator('', 4);
            _buffer = createBuffer();
        }

        private function createBuffer():void
        {
            var buffer:RespnoseBuffer =
                new ResponseBuffer(new ResponseParser());
            buffer.addEventListener(IMAPResponseEvent.RECEIVE, onReceive);
            buffer.addEventListener(IMAPErrorEvent.PARSE_ERROR, onParseError);
            return buffer;
        }

        private function onReceive(e:IMAPResponseEvent):void
        {
            if (e.data is TaggedResponse) {
            } else if (e.data is UntaggedResponse) {
            } else if (e.data is ContinuationRequest) {
            }
        }

        private function onParseError(e:IMAPErrorEvent):void
        {
            //trace(e.message);
        }

        public function connect(host:String, port:uint=143):void
        {
            if (_socket != null && _socket.connected)
                throw new Error("Already connected.");
            _socket = createSocket();
            _socket.connect(host, port);
        }

        public function generateTag():String
        {
            return _tagGenerator.generate();
        }

        public function sendCommand(command:String, args:Array):void
        {
            var tag:String = generateTag();
        }

        public function disconnect():void
        {
            if (_socket && _socket.connected)
                _socket.close();
        }

        public function dispose():void
        {
            _socket       = null;
            _lastResponse = new IMAPResponse();
            _buffer       = createBuffer();
        }

        public function createSocket(useSSL:Boolean=false):Socket
        {
            var s:Socket = new Socket();
            s.addEventListener(Event.CONNECT, connectHandler);
            s.addEventListener(Event.CLOSE, closeHandler);
            s.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            s.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            s.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
            return s;
        }

        public function connectHandler(e:Event):void
        {
            dispatchEvent(e.clone());
        }

        public function closeHandler(e:Event):void
        {
            dispose();
            dispatchEvent(e.clone());
        }

        public function ioErrorHandler(e:IOErrorEvent):void
        {
            dispose();
            dispatchEvent(e.clone());
        }

        public function securityErrorHandler(e:SecurityErrorEvent):void
        {
            dispose();
            dispatchEvent(e.clone());
        }

        public function socketDataHandler(e:ProgressEvent):void
        {
            while (_socket && _socket.connected && _socket.bytesAvailable) {
                // obtain new data from socket
                var bytes:ByteArray = new ByteArray();
                _socket.readBytes(bytes, 0, _socket.bytesAvailable);
                bytes.position = 0;
                _buffer.writeBytes(bytes);
            }
        }
    }
}

