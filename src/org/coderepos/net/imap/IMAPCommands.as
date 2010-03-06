package org.coderepos.net.imap
{
    public class IMAPCommands
    {
        public static const CAPABILITY:String   = "CAPABILITY";
        public static const NOOP:String         = "NOOP";
        public static const LOGOUT:String       = "LOGOUT";
        public static const AUTHENTICATE:String = "AUTHENTICATE";
        public static const LOGIN:String        = "LOGIN";
        public static const SELECT:String       = "SELECT";
        public static const EXAMINE:String      = "EXAMINE";
        public static const CREATE:String       = "CREATE";
        public static const DELETE:String       = "DELETE";
        public static const RENAME:String       = "RENAME";
        public static const SUBSCRIBE:String    = "SUBSCRIBE";
        public static const UNSUBSCRIBE:String  = "UNSUBSCRIBE";
        public static const LIST:String         = "LIST";
        public static const LSUB:String         = "LSUB";
        public static const STATUS:String       = "STATUS";
        public static const APPEND:String       = "APPEND";
        public static const CHECK:String        = "CHECK";
        public static const CLOSE:String        = "CLOSE";
        public static const EXPUNGE:String      = "EXPUNGE";
        public static const SEARCH:String       = "SEARCH";
        public static const FETCH:String        = "FETCH";
        public static const STORE:String        = "STORE";
        public static const COPY:String         = "COPY";
        public static const UID:String          = "UID";

        // Thread and Sort
        public static const SORT:String          = "SORT";
        public static const THREAD:String        = "THREAD";


        // ACL extension [RFC2086]
        public static const ACL:String        = "ACL";
        public static const SETACL:String     = "SETACL";
        public static const DELETEACL:String  = "DELETEACL";
        public static const GETACL:String     = "GETACL";
        public static const LISTRIGHTS:String = "LISTRIGHTS";
        public static const MYRIGHTS:String   = "MYRIGHTS";

        // QUOTA extension [RFC2087]
        public static const QUOTA:String        = "QUOTA";
        public static const QUOTAROOT:String    = "QUOTAROOT";

        public static const GETQUOTA:String     = "GETQUOTA";
        public static const SETQUOTA:String     = "SETQUOTA";
        public static const GETQUOTAROOT:String = "GETQUOTAROOT";
    }
}

