package org.coderepos.net.mime.binary
{
    import flash.utils.ByteArray;

    public class RawBinaryHolder extends IBinaryHolder
    {
        private var _bin:ByteArray;

        public function RawBinaryHolder(bin:ByteArray)
        {
            _bin = bin;
        }

        public function load():ByteArray
        {
            _bin.position = 0;
            return _bin;
        }
    }
}

