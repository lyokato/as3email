package
{
    import flash.net.SharedObject;
    import flash.utils.ByteArray;
    import flash.desktop.NativeApplication;
    import flash.data.EncryptedLocalStore;
    import org.coderepos.net.smtp.SMTPConfig;
    import org.coderepos.net.pop.POPConfig;

    [Bindable]
    public class DemoSetting
    {
        public static function load():DemoSetting
        {

            var setting:DemoSetting = new DemoSetting();

            // load from SharedObject
            var so:SharedObject = SharedObject.getLocal(
                NativeApplication.nativeApplication.applicationID );

            // TODO: validation
            if ("smtp_host" in so.data)
                setting.smtp_host = so.data["smtp_host"];
            if ("smtp_port" in so.data)
                setting.smtp_port = so.data["smtp_port"];
            if ("smtp_username" in so.data)
                setting.smtp_username = so.data["smtp_username"];
            if ("smtp_tls" in so.data)
                setting.smtp_tls = so.data["smtp_tls"];
            if ("smtp_smtpauth" in so.data)
                setting.smtp_smtpauth = so.data["smtp_smtpauth"];
            if ("from_address" in so.data)
                setting.from_address = so.data["from_address"];
            if ("pop_host" in so.data)
                setting.pop_host = so.data["pop_host"];
            if ("pop_port" in so.data)
                setting.pop_port = so.data["pop_port"];
            if ("pop_username" in so.data)
                setting.pop_username = so.data["pop_username"];

            if ("pop_tls" in so.data)
                setting.pop_tls = so.data["pop_tls"];
            if ("pop_apop" in so.data)
                setting.pop_apop = so.data["pop_apop"];

            /* password should be encrypted!
            if (EncryptedLocalStore.getItem("smtp_password"))
                setting.smtp_password = b2s(EncryptedLocalStore.getItem("smtp_password"));
            if (EncryptedLocalStore.getItem("pop_password"))
                setting.pop_password = b2s(EncryptedLocalStore.getItem("pop_password"));
            */
            if ("smtp_password" in so.data)
                setting.smtp_password = so.data["smtp_password"];
            if ("pop_password" in so.data)
                setting.pop_password = so.data["pop_password"];

            return setting;
        }

        public var smtp_host:String;
        public var smtp_port:String;
        public var smtp_username:String;
        public var smtp_password:String;
        public var smtp_tls:Boolean;
        public var smtp_smtpauth:Boolean;

        public var pop_host:String;
        public var pop_port:String;
        public var pop_username:String;
        public var pop_password:String;
        public var pop_tls:Boolean;
        public var pop_apop:Boolean;

        public var from_address:String;

        public function DemoSetting()
        {
            smtp_host     = "";
            smtp_port     = "25";
            smtp_username = "";
            smtp_password = "";
            smtp_tls      = false;
            smtp_smtpauth = false;

            pop_host      = "";
            pop_port      = "110";
            pop_username  = "";
            pop_password  = "";
            pop_tls       = false;
            pop_apop      = false;

            from_address   = "";
        }

        public function genSMTPConfig():SMTPConfig
        {
            // TODO: validation
            var c:SMTPConfig = new SMTPConfig();
            c.host          = smtp_host;
            c.port          = uint(smtp_port);
            c.username      = smtp_username;
            c.password      = smtp_password;
            c.overTLS       = smtp_tls;
            c.useSMTPAuth   = smtp_smtpauth;
            // c.timeout
            return c;
        }

        public function genPOPConfig():POPConfig
        {
            // TODO: validation
            var c:POPConfig = new POPConfig();
            c.host          = pop_host;
            c.port          = uint(pop_port);
            c.username      = pop_username;
            c.password      = pop_password;
            c.overTLS       = pop_tls;
            c.useAPOP       = pop_apop;
            c.storeOnServer = true;
            c.expiration    = 0;
            // c.timeout
            return c;
        }

        public function save():void
        {
            // save to SharedObject
            var so:SharedObject = SharedObject.getLocal(
                NativeApplication.nativeApplication.applicationID );

            so.data["smtp_host"]     = smtp_host;
            so.data["smtp_port"]     = smtp_port;
            so.data["smtp_username"] = smtp_username;
            so.data["smtp_tls"]      = smtp_tls;
            so.data["smtp_smtpauth"] = smtp_smtpauth;
            so.data["from_address"]  = from_address;
            so.data["pop_host"]      = pop_host;
            so.data["pop_port"]      = pop_port;
            so.data["pop_username"]  = pop_username;
            so.data["pop_tls"]       = pop_tls;
            so.data["pop_apop"]      = pop_apop;

            /* password should be encrypted!
            EncryptedLocalStore.setItem("smtp_password", s2b(smtp_password));
            EncryptedLocalStore.setItem("pop_password", s2b(pop_password));
            */
            so.data["pop_password"]    = pop_password;
            so.data["smtp_password"]   = smtp_password;
        }

        private static function b2s(b:ByteArray):String
        {
            b.position = 0;
            return b.readUTFBytes(b.length);
        }

        private static function s2b(s:String):ByteArray
        {
            var b:ByteArray = new ByteArray();
            b.writeUTFBytes(s);
            b.position = 0;
            return b;
        }
    }
}

