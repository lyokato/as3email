package org.coderepos.net.mime.binary
{
    import flash.utils.ByteArray;
    import flash.desktop.File;
    import flash.desktop.FileStream;
    import flash.desktop.FileMode;

    // This class is just for AIR
    public class FileStreamBinaryHolder extends IBinaryHolder
    {
        private var _path:String;

        public function FileStreamBinaryHolder(path:String)
        {
            _path = File.applicationStorageDirectory.resolvePath(path);
        }

        public function load():ByteArray
        {
            var stream:FileStream = new FileStream();
            stream.open(_path, FileMode.READ);
            var loaded:ByteArray = stream.readUTFBytes(stream.bytesAvailable);
            stream.close();
            loaded.position = 0;
            return loaded;
        }
    }
}

