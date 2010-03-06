package org.coderepos.net.mime
{
    // RFC1327
    public class MIMEPriority
    {
        public static const URGENT:String     = "urgent";
        public static const NORMAL:String     = "normal";
        public static const NON_URGENT:String = "non-urgent";

        public static function fromMSMailPriority(str:String):String
        {
            var text:String;
            str = str.toLowerCase();
            switch (str) {
                case "highest":
                    text = URGENT;
                    break;
                case "high":
                    text = URGENT;
                    break;
                case "normal":
                    text = NORMAL;
                    break;
                case "low":
                    text = NON_URGENT;
                    break;
                default:
                    text = NORMAL;
            }
            return text;
        }

        public static function fromXPriority(str:String):String
        {
            var text:String;
            switch (str) {
                case "1":
                    text = URGENT;
                    break;
                case "2":
                    text = URGENT;
                    break;
                case "3":
                    text = NORMAL;
                    break;
                case "4":
                    text = NON_URGENT;
                    break;
                case "5":
                    text = NON_URGENT;
                    break;
                default:
                    text = NORMAL;
            }
            return text;
        }

        public static function getMSMailPriority(str:String):String
        {
            var text:String = "";
            switch (str) {
                case URGENT:
                    text = "High";
                    break;
                case NORMAL:
                    text = "Normal";
                    break;
                case NON_URGENT:
                    text = "Low";
                    break;
                default:
                    text = "Normal";
                    //throw new Error("Unknown priority: " + str);
            }
            return text;
        }

        public static function getXPriority(str:String):String
        {
            var text:String = "";
            switch (str) {
                case URGENT:
                    text = "1";
                    break;
                case NORMAL:
                    text = "3";
                    break;
                case NON_URGENT:
                    text = "5";
                    break;
                default:
                    text = "3";
                    //throw new Error("Unknown priority: " + str);
            }
            return text;
        }
    }
}

