package org.coderepos.net.smtp.commands
{
    import flash.utils.ByteArray;

    public class AUTH implements ISMTPCommand
    {
        private var _mechName:String;
        private var _start:String;

        public function AUTH(mechName:String, start:String="")
        {
            _mechName = mechName;
            _start    = start;
        }

        public function toByteArray():ByteArray
        {
            var b:ByteArray = new ByteArray();
            b.writeUTFBytes(valueOf());
            b.position = 0;
            return b;
        }

        public function valueOf():String
        {
            var value:String = "AUTH " + _mechName;
            if (_start != null && _start.length > 0) {
                value += " ";
                value += _start;
            }
            value += "\r\n";
            return value;
        }
    }
}
