package org.coderepos.net.imap.parser
{
    public class Token {

        public var type:String;
        public var value:String;

        public function Token(type:String, value:String)
        {
            this.type = type;
            this.value = value;
        }

        public function get isAtom():Boolean
        {
            return (type == TokenType.ATOM
                 || type == TokenType.NUMBER
                 || type == TokenType.NIL
                 || type == TokenType.LBRA
                 || type == TokenType.RBRA
                 || type == TokenType.PLUS);
        }

        public function get isString():Boolean
        {
            return (type == TokenType.QUOTED
                 || type == TokenType.LITERAL
                 || type == TokenType.NIL);
        }
    }
}

