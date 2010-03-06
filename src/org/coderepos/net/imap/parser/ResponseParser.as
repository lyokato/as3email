package org.coderepos.net.imap.parser
{
    import org.coderepos.net.imap.data.*;
    import org.coderepos.net.imap.*;

    public class ResponseParser implements IResponseParser
    {
        private var _str:String;
        private var _pos:uint;
        private var _lexState:String;
        private var _token:Token;

        public function ResponseParser() { }

        public function parse(str:String):*
        {
            _str      = str;
            _pos      = 0;
            _lexState = Expressions.BEG;
            _token    = null;

            var token:Token = lookAhead();
            var result:*;
            switch (token.type) {
                case TokenType.PLUS:
                    clearTokenIfMatch(TokenType.PLUS);
                    clearTokenIfMatch(TokenType.SPACE);
                    result = new ContinuationRequest(getRespText(), str);
                    break;
                case TokenType.STAR:
                    result = getResponseUntagged();
                    break;
                default:
                    result = getResponseTagged();
                    break;
            }
            clearTokenIfMatch(TokenType.CRLF);
            clearTokenIfMatch(TokenType.EOF);
            return result;
        }

        public function getResponseTagged():TaggedResponse
        {
            var tag:String = getAtom();
            clearTokenIfMatch(TokenType.SPACE);
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            return new TaggedResponse(tag, name, getRespText(), _str);
        }

        public function getResponseUntagged():UntaggedResponse
        {
            clearTokenIfMatch(TokenType.STAR);
            clearTokenIfMatch(TokenType.SPACE);
            var token:Token = lookAhead();
            if (token.type == TokenType.NUMBER) {
                return getNumericResponse();
            } else if (token.type == TokenType.ATOM) {
                var ret:*;
                switch (token.value) {
                    case IMAPResponseStatus.OK:
                    case IMAPResponseStatus.NO:
                    case IMAPResponseStatus.BAD:
                    case IMAPResponseStatus.BYE:
                    case IMAPResponseStatus.PREAUTH:
                        ret = getResponseCond();
                        break;
                    //case IMAPCommands.FLAGS:
                    case "FLAGS":
                        ret = getFlagsResponse();
                        break;
                    case IMAPCommands.LIST:
                    case IMAPCommands.LSUB:
                        ret = getListResponse();
                        break;
                    case IMAPCommands.QUOTA:
                        ret = getQuotaResponse();
                        break;
                    case IMAPCommands.QUOTAROOT:
                        ret = getQuotaRootResponse();
                        break;
                    case IMAPCommands.ACL:
                        ret = getACLResponse();
                        break;
                    case IMAPCommands.SEARCH:
                    case IMAPCommands.SORT:
                        ret = getSearchResponse();
                        break;
                    case IMAPCommands.THREAD:
                        ret = getThreadResponse();
                        break;
                    case IMAPCommands.STATUS:
                        ret = getStatusResponse();
                        break;
                    case IMAPCommands.CAPABILITY:
                        ret = getCapabilityResponse();
                        break;
                    default:
                        ret = getTextResponse();
                }
                return ret;
            } else {
                parseError("Unexpected token");
                return null;
            }
        }

        public function getResponseCond():UntaggedResponse
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            return new UntaggedResponse(name, getRespText(), _str);
        }

        public function getNumericResponse():UntaggedResponse
        {
            var n:Number = getNumber();
            clearTokenIfMatch(TokenType.SPACE);
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            var res:UntaggedResponse;
            switch (name) {
                case "EXISTS":
                case "RECENT":
                case "EXPUNGE":
                    res = new UntaggedResponse(name, n, _str);
                    break;
                case "FETCH":
                    shiftToken();
                    clearTokenIfMatch(TokenType.SPACE);
                    var data:FetchData = new FetchData(n, getMsgAtt());
                    res = new UntaggedResponse(name, data, _str);
                    break;
            }
            return res;
        }

        public function getMsgAtt():Object
        {
            clearTokenIfMatch(TokenType.LPAR);
            var attr:Object = new Object();
            while (true) {
                var t:Token = lookAhead();
                if (t.type == TokenType.RPAR) {
                    shiftToken();
                    break;
                } else if(t.type == TokenType.SPACE) {
                    shiftToken();
                    t = lookAhead();
                }
                var result:Array;
                switch (t.value) {
                    case "ENVELOPE":
                        result = getEnvelopeData();
                        break;
                    case "FLAGS":
                        result = getFlagsData();
                        break;
                    case "INTERNALDATE":
                        result = getInternaldateData();
                        break;
                    case "RFC822.HEADER":
                    case "RFC822.TEXT":
                        result = getRFC822Text();
                        break;
                    case "RFC822.SIZE":
                        result = getRFC822Size();
                        break;
                    case "BODY":
                    case "BODYSTRUCTOR":
                        result = getBodyData();
                        break;
                    case "UID":
                        result = getUIDData();
                        break;
                    default:
                }
                attr[result[0]] = result[1];
            }
            return attr;
        }

        public function getEnvelopeData():Array
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            return [name, getEnvelope()];
        }

        public function getEnvelope():Envelope
        {
            _lexState = Expressions.DATA;
            var result:Envelope = null;
            var t:Token = lookAhead();
            if (t.type == TokenType.NIL) {
                shiftToken();
            } else {
                clearTokenIfMatch(TokenType.LPAR);
                var date:String = getNString();
                clearTokenIfMatch(TokenType.SPACE);
                var subject:String = getNString();
                clearTokenIfMatch(TokenType.SPACE);
                var from:Array = getAddressList();
                clearTokenIfMatch(TokenType.SPACE);
                var sender:Array = getAddressList();
                clearTokenIfMatch(TokenType.SPACE);
                var replyTo:Array = getAddressList();
                clearTokenIfMatch(TokenType.SPACE);
                var to:Array = getAddressList();
                clearTokenIfMatch(TokenType.SPACE);
                var cc:Array = getAddressList();
                clearTokenIfMatch(TokenType.SPACE);
                var bcc:Array = getAddressList();
                clearTokenIfMatch(TokenType.SPACE);
                var inReplyTo:String = getNString();
                clearTokenIfMatch(TokenType.SPACE);
                var messageID:String = getNString();
                clearTokenIfMatch(TokenType.RPAR);
                result = new Envelope(date, subject, from, sender, replyTo, to, cc, bcc, inReplyTo, messageID);
            }
            _lexState = Expressions.BEG;
            return result;
        }

        public function getFlagsData():Array
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            return [name, getFlagsList()];
        }

        public function getInternaldateData():Array
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            t = clearTokenIfMatch(TokenType.QUOTED);
            return [name, t.value];
        }

        public function getRFC822Text():Array
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            return [name, getNString()];
        }

        public function getRFC822Size():Array
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            return [name, getNumber()];
        }

        public function getBodyData():Array
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            t = lookAhead();
            if (t.type == TokenType.SPACE) {
                shiftToken();
                return [name, getBody()];
            }
            name += getSection();
            t = lookAhead();
            if (t.type == TokenType.ATOM) {
                name += t.value;
                shiftToken();
            }
            clearTokenIfMatch(TokenType.SPACE);
            return [name, getNString()];
        }

        //XXX: check type of response
        public function getBody():*
        {
            _lexState = Expressions.DATA;
            var result:* = null;
            var t:Token = lookAhead();
            if (t.type == TokenType.NIL) {
                shiftToken();
            } else {
                clearTokenIfMatch(TokenType.LPAR);
                t = lookAhead();
                if (t.type == TokenType.LPAR) {
                    result = getBodyTypeMPart();
                } else {
                    result = getBodyTypeSinglePart();
                }
                clearTokenIfMatch(TokenType.RPAR);
            }
            _lexState = Expressions.BEG;
            return result;
        }

        //XXX: check type of response, use interface?
        public function getBodyTypeSinglePart():*
        {
            var t:Token = lookAhead();
            switch (t.value) {
                case "TEXT":
                    return getBodyTypeText();
                    break;
                case "MESSAGE":
                    return getBodyTypeMessage();
                    break;
                default:
                    return getBodyTypeBasic();
            }
        }

        public function getBodyTypeBasic():BodyTypeBasic
        {
            var mtypes:Array = getMediaType();
            var mType:String = mtypes[0];
            var mSubType:String = mtypes[1];
            var t:Token = lookAhead();
            if (t.type == TokenType.RPAR) {
                return new BodyTypeBasic(mType, mSubType);
            }
            clearTokenIfMatch(TokenType.SPACE);
            var fields:Array = getBodyFields();
            var parts:Array = getBodyExtSinglePart();
            return new BodyTypeBasic(
                mType, mSubType,
                fields[0], fields[1], fields[2], fields[3], fields[4],
                parts[0], parts[1], parts[2], parts[3] );
        }

        public function getBodyTypeText():BodyTypeText
        {
            var mtypes:Array = getMediaType();
            var mType:String = mtypes[0];
            var mSubType:String = mtypes[1];
            clearTokenIfMatch(TokenType.SPACE);
            var fields:Array = getBodyFields();
            clearTokenIfMatch(TokenType.SPACE);
            var lines:Number = getNumber();
            var parts:Array = getBodyExtSinglePart();
            return new BodyTypeText(
                mType, mSubType,
                fields[0], fields[1], fields[2], fields[3], fields[4],
                lines,
                parts[0], parts[1], parts[2], parts[3] );
        }

        public function getBodyTypeMessage():BodyTypeMessage
        {
            var mtypes:Array = getMediaType();
            var mType:String = mtypes[0];
            var mSubType:String = mtypes[1];
            clearTokenIfMatch(TokenType.SPACE);
            var fields:Array = getBodyFields();
            clearTokenIfMatch(TokenType.SPACE);
            var env:Envelope = getEnvelope();
            clearTokenIfMatch(TokenType.SPACE);
            // XXX: check type, IBodyType?
            var b:* = getBody();
            clearTokenIfMatch(TokenType.SPACE);
            var line:Number = getNumber();
            var parts:Array = getBodyExtSinglePart();
            return new BodyTypeMessage(
                mType, mSubType,
                fields[0], fields[1], fields[2], fields[3], fields[4],
                env, b, line,
                parts[0], parts[1], parts[2], parts[3] );
        }

        public function getBodyTypeMPart():BodyTypeMultipart
        {
            var parts:Array = [];
            while (true) {
                var t:Token = lookAhead();
                if (t.type == TokenType.SPACE) {
                    shiftToken();
                    break;
                }
                parts.push(getBody());
            }
            var mType:String = "MULTIPART";
            var mSubType:String = getCaseInsensitiveString();
            var mparts:Array = getBodyExtMPart();
            return new BodyTypeMultipart(
                mType, mSubType, parts,
                mparts[0], mparts[1], mparts[2], mparts[3] );
        }

        public function getMediaType():Array
        {
            var mType:String = getCaseInsensitiveString();
            clearTokenIfMatch(TokenType.SPACE);
            var mSubType:String = getCaseInsensitiveString();
            return [mType, mSubType];
        }

        public function getBodyFields():Array
        {
            var param:Object = getBodyFieldParam();
            clearTokenIfMatch(TokenType.SPACE);
            var contentID:String = getNString();
            clearTokenIfMatch(TokenType.SPACE);
            var desc:String = getNString();
            clearTokenIfMatch(TokenType.SPACE);
            var enc:String = getCaseInsensitiveString();
            clearTokenIfMatch(TokenType.SPACE);
            var size:Number = getNumber();
            return [param, contentID, desc, enc, size];
        }

        public function getBodyFieldParam():Object
        {
            var t:Token = lookAhead();
            if (t.type == TokenType.NIL) {
                shiftToken();
                return null;
            }
            clearTokenIfMatch(TokenType.LPAR);
            var param:Object = {};
            while (true) {
                t = lookAhead();
                if (t.type == TokenType.RPAR) {
                    shiftToken();
                    break;
                } else if (t.type == TokenType.SPACE) {
                    shiftToken();
                }
                var name:String = getCaseInsensitiveString();
                clearTokenIfMatch(TokenType.SPACE);
                var val:String = getString();
                param[name] = val;
            }
            return param;
        }

        public function getBodyExtSinglePart():Array
        {
            var t:Token = lookAhead();
            if (t.type == TokenType.SPACE) {
                shiftToken();
            } else {
                return null;
            }
            var md5:String = getNString();

            t = lookAhead();
            if (t.type == TokenType.SPACE) {
                shiftToken();
            } else {
                return [md5];
            }
            var disposition:ContentDisposition = getBodyFieldDsp();

            t = lookAhead();
            if (t.type == TokenType.SPACE) {
                shiftToken();
            } else {
                return [md5, disposition];
            }
            var language:Array = getBodyFieldLang();

            t = lookAhead();
            if (t.type == TokenType.SPACE) {
                shiftToken();
            } else {
                return [md5, disposition, language];
            }

            var extension:Array = getBodyExtensions();
            return [md5, disposition, language, extension];
        }

        public function getBodyExtMPart():Array
        {
            var t:Token = lookAhead();
            if (t.type == TokenType.SPACE) {
                shiftToken();
            } else {
                return null;
            }

            var param:Object = getBodyFieldParam();

            t = lookAhead();
            if (t.type == TokenType.SPACE) {
                shiftToken();
            } else {
                return [param];
            }

            var disposition:ContentDisposition = getBodyFieldDsp();
            clearTokenIfMatch(TokenType.SPACE);
            var language:Array = getBodyFieldLang();
            t = lookAhead();
            if (t.type == TokenType.SPACE) {
                shiftToken();
            } else {
                return [param, disposition, language];
            }

            var extension:Array = getBodyExtensions();
            return [param, disposition, language, extension];
        }

        public function getBodyFieldDsp():ContentDisposition
        {
            var t:Token = lookAhead();
            if (t.type == TokenType.NIL) {
                shiftToken();
                return null;
            }
            clearTokenIfMatch(TokenType.LPAR);
            var dspType:String = getCaseInsensitiveString();
            clearTokenIfMatch(TokenType.SPACE);
            var param:Object = getBodyFieldParam();
            clearTokenIfMatch(TokenType.RPAR);
            return new ContentDisposition(dspType, param);
        }

        public function getBodyFieldLang():Array
        {
            var t:Token = lookAhead();
            if (t.type == TokenType.LPAR) {
                shiftToken();
                var result:Array = [];
                while (true) {
                    t = lookAhead();
                    if (t.type == TokenType.RPAR) {
                        shiftToken();
                        return result;
                    } else if(t.type == TokenType.SPACE) {
                        shiftToken();
                    }
                    result.push(getCaseInsensitiveString());
                }
            } else {
                var lang:String = getNString();
                if (lang!=null) {
                    return [lang.toUpperCase()];
                } else {
                    return null;
                }
            }
            return null;
        }

        public function getBodyExtensions():Array
        {
            var result:Array = [];
            while (true) {
                var t:Token = lookAhead();
                if (t.type == TokenType.RPAR) {
                    return result;
                } else if (t.type == TokenType.SPACE) {
                    shiftToken();
                }
                result.push(getBodyExtension());
            }
            return null;
        }

        //XXX: check type
        public function getBodyExtension():*
        {
            var t:Token = lookAhead();
            var result:Array = new Array();
            switch (t.type) {
                case TokenType.LPAR:
                    shiftToken();
                    result = getBodyExtensions();
                    clearTokenIfMatch(TokenType.RPAR);
                    return result;
                    break;
                case TokenType.NUMBER:
                    return getNumber();
                    break;
                default:
                    return getNString();
            }
        }

        public function getSection():String
        {
            var str:String = "";
            var t:Token = clearTokenIfMatch(TokenType.LBRA);
            str += t.value;
            t = clearTokenIfMatch(TokenType.ATOM, TokenType.NUMBER, TokenType.RBRA);
            str += t.value;
            if (t.type == TokenType.RBRA) {
                return str;
            }
            t = lookAhead();
            if (t.type == TokenType.SPACE) {
                shiftToken();
                str += t.value;
                t = clearTokenIfMatch(TokenType.LPAR);
                str += t.value;
                while (true) {
                    t = lookAhead();
                    if (t.type == TokenType.RPAR) {
                        str += t.value;
                        shiftToken();
                        break;
                    } else if (t.type == TokenType.SPACE) {
                        shiftToken();
                        str += t.value;
                    }
                    str += formatString(getAString());
                }
            }
            t = clearTokenIfMatch(TokenType.RBRA);
            str += t.value;
            return str;
        }

        public function formatString(str:String):String
        {
            if (str.length == 0) {
                return '""';
            } else if (str.match(/[\x80-\xff\r\n]/)!=null) {
                return "{" + str.length.toString() + "}" + "\r\n" + str;
            } else if (str.match(/[(){ \x00-\x1f\x7f%*"\\]/)!=null) {  // "
                return '"' + str.replace(/["\\]/g, "\\\\\\&") + '"';   // '
            } else {
                return str;
            }
        }

        public function getUIDData():Array
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            return [name, getNumber()];
        }

        public function getTextResponse():UntaggedResponse
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            _lexState = Expressions.TEXT;
            t = clearTokenIfMatch(TokenType.TEXT);
            _lexState = Expressions.BEG;
            return new UntaggedResponse(name, t.value, _str);
        }

        public function getFlagsResponse():UntaggedResponse
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            return new UntaggedResponse(name, getFlagsList(), _str);
        }

        public function getListResponse():UntaggedResponse
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            return new UntaggedResponse(name, getMailboxList(), _str);
        }

        public function getMailboxList():MailboxList
        {
            var attr:Array = getFlagsList();
            clearTokenIfMatch(TokenType.SPACE);
            var t:Token = clearTokenIfMatch(TokenType.QUOTED, TokenType.NIL);
            var delim:String = null;
            if (t.type != TokenType.NIL) {
                delim = t.value;
            }
            clearTokenIfMatch(TokenType.SPACE);
            var name:String = getAString();
            return new MailboxList(attr, delim, name);
        }

        public function getQuotaResponse():UntaggedResponse
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            var mailbox:String = getAString();
            clearTokenIfMatch(TokenType.SPACE);
            clearTokenIfMatch(TokenType.LPAR);
            t = lookAhead();
            var data:MailboxQuota;
            if (t.type == TokenType.RPAR) {
                shiftToken();
                data = new MailboxQuota(mailbox, null, null);
                return new UntaggedResponse(name, data, _str);
            } else if (t.type == TokenType.ATOM) {
                shiftToken();
                clearTokenIfMatch(TokenType.NUMBER);
                var usage:String = t.value;
                clearTokenIfMatch(TokenType.SPACE);
                t = clearTokenIfMatch(TokenType.NUMBER);
                var quota:String = t.value;
                clearTokenIfMatch(TokenType.RPAR);
                data = new MailboxQuota(mailbox, usage, quota);
                return new UntaggedResponse(name, data, _str);
            } else {
                parseError("Unexpected token");
                return null;
            }
        }

        public function getQuotaRootResponse():UntaggedResponse
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            var mailbox:String = getAString();
            var quotaroots:Array = [];
            while (true) {
                t = lookAhead();
                if (t.type != TokenType.SPACE) {
                    break;
                }
                shiftToken();
                quotaroots.push(getAString());
            }
            var data:MailboxQuotaRoot = new MailboxQuotaRoot(mailbox, quotaroots);
            return new UntaggedResponse(name, data, _str);
        }

        public function getACLResponse():UntaggedResponse
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            var mailbox:String = getAString();
            var data:Array = [];
            t = lookAhead();
            if (t.type == TokenType.SPACE) {
                shiftToken();
                while (true) {
                    t = lookAhead();
                    if (t.type == TokenType.CRLF) {
                        break;
                    } else if (t.type == TokenType.SPACE) {
                        shiftToken();
                    }
                    var user:String =getAString();
                    clearTokenIfMatch(TokenType.SPACE);
                    var rights:String = getAString();
                    data.push(new MailboxACLItem(user, rights));
                }
            }
            return new UntaggedResponse(name, data, _str);
        }

        public function getSearchResponse():UntaggedResponse
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            t = lookAhead();
            var data:Array = [];
            if (t.type == TokenType.SPACE) {
                shiftToken();
                while (true) {
                    t = lookAhead();
                    if (t.type == TokenType.CRLF) {
                        break;
                    } else if (t.type == TokenType.SPACE) {
                        shiftToken();
                    }
                    data.push(getNumber());
                }
            }
            return new UntaggedResponse(name, data, _str);
        }

        public function getThreadResponse():UntaggedResponse
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            t = lookAhead();
            var threads:Array = [];
            if (t.type == TokenType.SPACE) {
                while (true) {
                    shiftToken();
                    t = lookAhead();
                    if (t.type == TokenType.LPAR) {
                        threads.push(getThreadBranch(t));
                    } else if (t.type == TokenType.CRLF) {
                        break; 
                    }
                }
            }
            return new UntaggedResponse(name, threads, _str);
        }

        public function getThreadBranch(t:Token):ThreadMember
        {
            var rootMember:ThreadMember;
            var lastMember:ThreadMember;

            while (true) {
                shiftToken();
                var t:Token = lookAhead();
                if (t.type == TokenType.NUMBER) {
                    var newMember:ThreadMember = new ThreadMember(getNumber(), []);
                    if (rootMember==null)
                        rootMember = newMember;
                    else if (lastMember != null)
                        lastMember.children.push(newMember);
                    lastMember = newMember;
                } else if (t.type == TokenType.SPACE) {
                } else if (t.type == TokenType.LPAR) {
                    if (rootMember == null)
                        lastMember = rootMember = new ThreadMember(0, []);
                    lastMember.children.push(getThreadBranch(t));
                } else if (t.type == TokenType.RPAR) {
                    break;
                }
            }
            return null;
        }

        public function shiftToken():void
        {
            _token = null;
        }

        public function getStatusResponse():UntaggedResponse
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var n:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            var mailbox:String = getAString();
            clearTokenIfMatch(TokenType.SPACE);
            clearTokenIfMatch(TokenType.LPAR);
            var attr:Object = {};
            while (true) {
                t = lookAhead();
                if (t.type == TokenType.RPAR) {
                    shiftToken();
                    break;
                } else if (TokenType.SPACE) {
                    shiftToken();
                }
                t = clearTokenIfMatch(TokenType.ATOM);
                var k:String = t.value.toUpperCase();
                clearTokenIfMatch(TokenType.SPACE);
                var v:Number = getNumber();
                attr[k] = v;
            }
            var data:StatusData = new StatusData(mailbox, attr);
            return new UntaggedResponse(n, data, _str);
        }

        public function getCapabilityResponse():UntaggedResponse
        {
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var n:String = t.value.toUpperCase();
            clearTokenIfMatch(TokenType.SPACE);
            var data:Array = new Array();
            while (true) {
                t = lookAhead();
                if (t.type == TokenType.CRLF) {
                    break;
                } else if (t.type == TokenType.SPACE) {
                    shiftToken();
                }
                data.push(getAtom().toUpperCase());
            }
            return new UntaggedResponse(n, data, _str);
        }

        public function getRespText():ResponseText
        {
            _lexState = Expressions.RTEXT;
            var t:Token = lookAhead();
            var c:ResponseCode = null;
            if (t.type == TokenType.LBRA) {
                c = getRespTextCode();
            }
            t = clearTokenIfMatch(TokenType.TEXT);
            _lexState = Expressions.BEG;
            return new ResponseText(c, t.value);
        }

        public function getRespTextCode():ResponseCode
        {
            _lexState = Expressions.BEG;
            clearTokenIfMatch(TokenType.LBRA);
            var t:Token = clearTokenIfMatch(TokenType.ATOM);
            var name:String = t.value.toUpperCase();
            var result:ResponseCode = null;
            switch (name) {
                case IMAPResponseCode.ALERT:
                case IMAPResponseCode.PARSE:
                case IMAPResponseCode.READONLY:
                case IMAPResponseCode.READWRITE:
                case IMAPResponseCode.TRYCREATE:
                case IMAPResponseCode.NOMODSEQ:
                    result = new ResponseCode(name, null);
                    break;
                case IMAPResponseCode.PERMANENTFLAGS:
                    clearTokenIfMatch(TokenType.SPACE);
                    result = new ResponseCode(name, getFlagsList());
                    break;
                case IMAPStatusType.UIDVALIDITY:
                case IMAPStatusType.UIDNEXT:
                case IMAPStatusType.UNSEEN:
                    clearTokenIfMatch(TokenType.SPACE);
                    result = new ResponseCode(name, getNumber());
                    break;
                default:
                    clearTokenIfMatch(TokenType.SPACE);
                    _lexState = Expressions.CTEXT;
                    t = clearTokenIfMatch(TokenType.TEXT);
                    _lexState = Expressions.BEG;
                    result = new ResponseCode(name, t.value);
            }
            clearTokenIfMatch(TokenType.RBRA);
            _lexState = Expressions.RTEXT;
            return result;
        }


        public function getAddressList():Array
        {
            var t:Token = lookAhead();
            if (t.type ==  TokenType.NIL) {
                shiftToken();
                return null;
            } else {
                var result:Array = new Array();
                clearTokenIfMatch(TokenType.LPAR);
                while (true) {
                    t = lookAhead();
                    if (t.type == TokenType.RPAR) {
                        shiftToken();
                        break;
                    } else if (t.type == TokenType.SPACE) {
                        shiftToken();
                    }
                    result.push(getAddress());
                }
                return result;
            }
        }

        public function getAddress():Address
        {
            clearTokenIfMatch(TokenType.LPAR);
            var target:String = _str.substring(_pos);
            var r:AddressParserResult = AddressParser.parse(target);
            if (r!=null) {
                _pos += r.lastIndex;
                return r.address;
            } else {
                var name:String = getNString();
                clearTokenIfMatch(TokenType.SPACE);
                var route:String = getNString();
                clearTokenIfMatch(TokenType.SPACE);
                var mailbox:String = getNString();
                clearTokenIfMatch(TokenType.SPACE);
                var host:String = getNString();
                clearTokenIfMatch(TokenType.RPAR);
                return new Address(name, route, mailbox, host);
            }
        }

        public function getFlagsList():Array
        {
            var target:String = _str.substring(_pos);
            var r:FlagParserResult = FlagParser.parse(target);
            if (r!=null) {
                _pos += r.lastIndex;
                return r.flags;
            } else {
                parseError("Unexpected token");
                return null;
            }
        }

        public function getNString():String
        {
            var t:Token = lookAhead();
            if (t.type == TokenType.NIL) {
                shiftToken();
                return null;
            } else {
                return getString();
            }
        }

        public function getAString():String
        {
            var t:Token = lookAhead();
            if (t.isString) {
                return getString();
            } else {
                return getAtom();
            }
        }

        public function getString():String
        {
            var t:Token = lookAhead();
            if (t.type == TokenType.NIL) {
                shiftToken();
                return null;
            } else {
                t = clearTokenIfMatch(TokenType.QUOTED, TokenType.LITERAL);
                return t.value;
            }
        }

        public function getCaseInsensitiveString():String
        {
            var t:Token = lookAhead();
            if (t.type == TokenType.NIL) {
                shiftToken();
                return null;
            }
            t = clearTokenIfMatch(TokenType.QUOTED, TokenType.LITERAL);
            return t.value.toUpperCase();
        }

        public function getAtom():String
        {
            var result:String = "";
            while (true) {
                var t:Token = lookAhead();
                if (t.isAtom) {
                    result += t.value;
                    shiftToken();
                } else {
                    if (result.length == 0) {
                        parseError("Unexpected token");
                    } else {
                        return result;
                    }
                }
            }
            return null;
        }

        public function getNumber():Number {
            var t:Token = lookAhead();
            if (t.type == TokenType.NIL) {
                shiftToken();
                return 0;
            }
            t = clearTokenIfMatch(TokenType.NUMBER);
            return Number(t.value);
        }

        public function getNilAtom():String
        {
            clearTokenIfMatch(TokenType.NIL);
            return null;
        }


        public function lookAhead():Token
        {
            if (_token == null) {
                _token = getNextToken();
            }
            return _token;
        }

        public function getNextToken():Token
        {
            //if (_pos >= _str.length)
            //    throw new Error("no more token.");

            var src:String = _str.substring(_pos);
            var r:Array;
            var len:uint;
            var val:String;
            switch (_lexState) {
                case Expressions.BEG:
                    r = src.match(new RegExp(Patterns.BEG));
                    if (r!=null) {
                        _pos += src.indexOf(r[0]) + r[0].length;
                        if (r[1]!=null) {
                            return new Token(TokenType.SPACE, r[1]);
                        } else if (r[2]!=null) {
                            return new Token(TokenType.NIL, r[2]);
                        } else if (r[3]!=null) {
                            return new Token(TokenType.NUMBER, r[3]);
                        } else if (r[4]!=null) {
                            return new Token(TokenType.ATOM, r[4]);
                        } else if (r[5]!=null) {
                            return new Token(TokenType.QUOTED,
                                r[5].replace(/\\(["\\])/, "$1")); // "
                        } else if (r[6]!=null) {
                            return new Token(TokenType.LPAR, r[6]);
                        } else if (r[7]!=null) {
                            return new Token(TokenType.RPAR, r[7]);
                        } else if (r[8]!=null) {
                            return new Token(TokenType.BSLASH, r[8]);
                        } else if (r[9]!=null) {
                            return new Token(TokenType.STAR, r[9]);
                        } else if (r[10]!=null) {
                            return new Token(TokenType.LBRA, r[10]);
                        } else if (r[11]!=null) {
                            return new Token(TokenType.RBRA, r[11]);
                        } else if (r[12]!=null) {
                            len = uint(r[12]);
                            val = _str.substr(_pos, len);
                            _pos += len;
                            return new Token(TokenType.LITERAL, val);
                        } else if (r[13]!=null) {
                            return new Token(TokenType.PLUS, r[13]);
                        } else if (r[14]!=null) {
                            return new Token(TokenType.PERCENT, r[14]);
                        } else if (r[15]!=null) {
                            return new Token(TokenType.CRLF, r[15]);
                        } else if (r[16]!=null) {
                            return new Token(TokenType.EOF, r[16]);
                        } else {
                            parseError("BEG RegExp is invalid");
                        }
                    } else {
                        parseError("Unexpected token.");
                    }
                    break;
                case Expressions.DATA:
                    r = src.match(new RegExp(Patterns.DATA));
                    if (r!=null) {
                        _pos += src.indexOf(r[0]) + r[0].length;
                        if (r[1] != null) {
                            return new Token(TokenType.SPACE, r[1]);
                        } else if (r[2] != null) {
                            return new Token(TokenType.NIL, r[2]);
                        } else if (r[3] != null) {
                            return new Token(TokenType.NUMBER, r[3]);
                        } else if (r[4] != null) {
                            return new Token(TokenType.QUOTED,
                                r[4].replace(/\\(["\\])/, "$1")); // "
                        } else if (r[5] != null) {
                            len = uint(r[5]);
                            val = _str.substr(_pos, len);
                            _pos += len;
                            return new Token(TokenType.LITERAL, val);
                        } else if (r[6] != null) {
                            return new Token(TokenType.LPAR, r[6]);
                        } else if (r[7] != null) {
                            return new Token(TokenType.RPAR, r[7]);
                        } else {
                            parseError("DATA RegExp is invalid");
                        }
                    } else {
                        parseError("DATA RegExp is invalid");
                    }
                    break;
                case Expressions.TEXT:
                    r = src.match(new RegExp(Patterns.TEXT));
                    if (r!=null) {
                        _pos += src.indexOf(r[0]) + r[0].length;
                        if (r[1]!=null) {
                            return new Token(TokenType.TEXT, r[1]);
                        } else {
                            parseError("TEXT RegExp is invalid");
                        }
                    } else {
                        parseError("TEXT RegExp is invalid");
                    }
                    break;
                case Expressions.RTEXT:
                    r = src.match(new RegExp(Patterns.RTEXT));
                    if (r!=null) {
                        _pos += src.indexOf(r[0]) + r[0].length;
                        if (r[1]!=null) {
                            return new Token(TokenType.LBRA, r[1]);
                        } else if (r[2]!=null) {
                            return new Token(TokenType.TEXT, r[2]);
                        } else {
                            parseError("RTEXT RegExp is invalid");
                        }
                    } else {
                        parseError("RTEXT RegExp is invalid");
                    }
                    break;
                case Expressions.CTEXT:
                    r = src.match(new RegExp(Patterns.CTEXT));
                    if (r!=null) {
                        _pos += src.indexOf(r[0]) + r[0].length;
                        if (r[1]!=null) {
                            return new Token(TokenType.TEXT, r[1]);
                        }
                    } else {
                        parseError("CTEXT RegExp is invalid");
                    }
                    break;
                default:
                    parseError("Unexpected token");
                    break;
            }
            return null;
        }

        public function clearTokenIfMatch(...args):Token
        {
            var token:Token = lookAhead();
            var matched:Boolean = false;
            for each(var type:String in args) {
                if (token.type == type) {
                    matched = true;
                    break;
                }
            }
            if (!matched) {
                parseError("token should be " + args.join(':'));
            }
            shiftToken();
            return token;
        }

        public function parseError(msg:String):void
        {
            throw new Error(msg);
        }
    }
}

