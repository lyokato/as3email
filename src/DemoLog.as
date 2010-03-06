package {
    public class DemoLog {
        [Bindable]
        public var log:String;
        public function DemoLog() { log = "" }
        public function append(str:String):void
        {
            log += str;
        }
        public function appendLine(str:String):void
        {
            log += str;
            log += "\n";
        }

        public function clear():void
        {
            log = "";
        }
    }
}
