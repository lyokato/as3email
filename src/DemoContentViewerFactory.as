package
{
    public class DemoContentViewerFactory
    {
        public static function getViwerForContentType(type:String):IDemoContentViewer
        {
            if (type.match(/^text\//) != null) {

            } else if (type.match(/^image\//) != null) {

            } else if (type.match(/^video\/flv/) != null) {

            }
        }
    }
}

