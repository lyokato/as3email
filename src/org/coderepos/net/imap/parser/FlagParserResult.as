package org.coderepos.net.imap.parser
{
    public class FlagParserResult
    {
        private var _pos:uint;
        private var _flags:Array;

        public function FlagParserResult(pos:uint, flags:Array)
        {
            _pos   = pos;
            _flags = flags;
        }

        public function get lastIndex():uint
        {
            return _pos;
        }

        public function get flags():Array
        {
            return _flags;
        }
    }
}
