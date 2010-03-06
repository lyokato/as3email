package org.coderepos.net.imap.parser
{
    public class Patterns
    {

        public static const BEG:String = '\\G(?:'
            + '( +)|' // SPACE
            + '(NIL)(?=[\\x80-\\xff(){ \\x00-\\x1f\\x7f%*"\\\\\\[\\]+])|' // NIL
            + '(\\d+)(?=[\\x80-\\xff(){ \\x00-\\x1f\\x7f%*"\\\\\\[\\]+])|'// NUMBER
            + '([^\\x80-\\xff(){ \\x00-\\x1f\\x7f%*"\\\\\\[\\]+]+)|'       // ATOM
            + '"((?:[^\\x00\\r\\n"\\\\]|\\\\["\\\\])*)"|'                 // QUOTED
            + '(\\()|'                                                    // LPAR
            + '(\\))|'                                                    // PAR
            + '(\\\\)|'                                                   // BSLASH
            + '(\\*)|'                                                    // STAR
            + '(\\[)|'                                                    // LBRA
            + '(\\])|'                                                    // RBRA
            + '\\{(\\d+)\\}\\r\\n|'                                       // LITERAL
            + '(\\+)|'                                                    // PLUS
            + '(%)|'                                                      // PERCENT
            + '(\\r\\n)|'                                                 // CRLF
            + '(\\z)'                                                     // EOF
            + ')';
        public static const DATA:String = '\\G(?:'
            + '( )|'                                      // SPACE
            + '(NIL)|'                                    // NIL
            + '(\\d+)|'                                   // NUMBER
            + '"((?:[^\\x00\\r\\n"\\\\]|\\\\["\\\\])*)"|' // QUOTED
            + '\\{(\\d+)\\}\\r\\n|'                       // LITERAL
            + '(\\()|'                                    // LPAR
            + '(\\)))';                                   // RPAR
        public static const TEXT:String = '\\G(?:([^\\x00\\r\\n]*))';
        public static const RTEXT:String = '\\G(?:(\\[)|([^\\x00\\r\\n]*))';
        public static const CTEXT:String = '\\G(?:([^\\x00\\r\\n\\]]*))';
        public static const FLAG:String = '\\\\([^\\x80-\\xff(){ \\x00-\\x1f\\x7f%"\\\\]+)|([^\\x80-\\xff(){ \\x00-\\x1f\\x7f%*"\\\\]+)';
        public static const ADDRESS:String = '\\G(?:NIL|"((?:[^\\x80-\\xff\\x00\\r\\n"\\\\]|\\\\["\\\\]*))") (?:NIL|"((?:[^\\x80-\\xff\\x00\\r\\n"\\\\]|\\\\["\\\\]*))") (?:NIL|"((?:[^\\x80-\\xff\\x00\\r\\n"\\\\]|\\\\["\\\\]*))") (?:NIL|"((?:[^\\x80-\\xff\\x00\\r\\n"\\\\]|\\\\["\\\\]*))")\)';
    }
}

