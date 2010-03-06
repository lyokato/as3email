package org.coderepos.net.imap.parser
{
    import org.coderepos.net.imap.data.Address;

    public class AddressParserResult
    {
        private var _pos:uint;
        private var _address:Address;

        public function AddressParserResult(pos:uint, address:Address)
        {
            _pos = pos;
            _address = address;
        }

        public function get lastIndex():uint
        {
            return _pos;
        }

        public function get address():Address
        {
            return _address;
        }
    }
}

