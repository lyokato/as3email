package org.coderepos.net.pop.uidstore
{
    public interface IUIDStore
    {
        function retrieveUIDTime(uid:String):Number;
        function hasUID(uid:String):Boolean;
        function storeUID(uid:String):void;
        function removeUID(uid:String):void;
        function save():void;
        function load():void;
    }
}

