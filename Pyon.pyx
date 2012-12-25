
cdef enum TokenTypes:
    END = 0
    QUOTED = 1
    BAREWORD = 2
    NUMBER = 3
    COMMA = 44
    OPEN_PAREN = 40
    CLOSE_PAREN = 41
    OPEN_BRACKET = 91
    CLOSE_BRACKET = 93
    OPEN_CURLY = 123
    CLOSE_CURLY = 125
    EQ_SIGN = 61
    COLON = 58

cdef class Token:
    cdef char type_
    cdef object value_
    def __repr__(Token self):
        if self.type_ == END: return "End()"
        if self.type_ == BAREWORD: return "Bareword(%r)" % self.value_
        if self.type_ == NUMBER: 
            if isinstance(self.value_,float):
                return "Number(%r)" % self.value_
            else:
                return "Number(%r)" % int(self.value_)
        if self.type_ == QUOTED: return "Quoted(%r)" % self.value_
        return "Syntax('%s')" % chr(self.type_)
    def __richcmp__(self,other,op):
        cdef Token tOther
        if op == 2: 
            if not isinstance(other,Token): return False
            tOther = <Token> other
            if tOther.type_ != self.type_: return False
            if tOther.value_ != self.value_: return False
            return True
        else:
            raise Exception("operation not supported: %s" % op)
            

cdef readNumber(char **stringPtr):
    cdef char* p = stringPtr[0]
    cdef char sign = 1
    if p[0] == 45: 
        sign = -1 # '-'
        p += 1
    if p[0] == 43: p += 1 # '+'
    cdef char floating = 0
    cdef int64_t beforeDecimal = 0
    cdef double afterDecimal = 0.0
    cdef int e = 0
    cdef char eSign = +1 
    cdef double multiplier = 0.1
    while p[0] >= 48 and p[0] <= 57: # 0-9
        beforeDecimal *= 10
        beforeDecimal += (p[0] - 48)
        p += 1
    if p[0] == 46: # '.'
        p += 1
        floating = 1
        while p[0] >= 48 and p[0] <= 57:
            afterDecimal += multiplier * (p[0] - 48)
            multiplier *= 0.1
            p += 1
    if p[0] == 101 or p[0] == 69: # 'e' or 'E'
        p += 1
        floating = 1
        if p[0] == 43: p += 1 # '+'
        if p[0] == 45: # '-'
            eSign = -1 
            p += 1
        while p[0] >= 48 and p[0] <= 57:
            e *= 10
            e += (p[0] - 48)
            p += 1
    stringPtr[0] = p
    cdef Token token = Token()
    token.type_ = NUMBER
    if not floating:
        token.value_ = sign * beforeDecimal
        return token
    cdef double out = sign * (beforeDecimal + afterDecimal)
    while e > 0:
        if eSign == +1: out *= 10
        if eSign == -1: out *= .1
        e -= 1
    token.value_ = out
    return token
        
cdef readBareword(char **stringPtr):
    cdef char* endAt = stringPtr[0]
    while True:
        endAt += 1
        if endAt[0] >= 97 and endAt[0] <= 122: continue # a-z
        if endAt[0] >= 65 and endAt[0] <= 90: continue # A-Z
        if endAt[0] >= 48 and endAt[0] <= 57: continue # 0-9
        if endAt[0] == 95: continue # '_'
        break
    cdef int length = endAt-stringPtr[0]
    cdef bytes out = PyBytes_FromStringAndSize(stringPtr[0],length)
    stringPtr[0] += length
    cdef Token token = Token()
    token.type_ = BAREWORD
    token.value_ = out
    return token

cdef readString(char ** stringPtr):
    cdef char quote = stringPtr[0][0]
    cdef char* startAt = stringPtr[0] + 1
    cdef char* endAt = startAt
    while endAt[0] != quote and endAt[0] != 0:
        endAt += 1
    cdef int length = endAt - startAt
    cdef bytes out = PyBytes_FromStringAndSize(startAt,length)
    stringPtr[0] += length + 2
    cdef Token token = Token()
    token.type_ = QUOTED
    token.value_ = out
    return token

cpdef tokenize(char* zstring):
    cdef list out = list()
    cdef char c 
    cdef char* p = zstring
    cdef Token token
    while True:
        c = p[0]
        if c == 32 or c == 9 or c == 10: p += 1 # whitespace
        elif c >= 97 and c <= 122: out.append(readBareword(&p)) # a-z
        elif c >= 65 and c <= 90:  out.append(readBareword(&p)) # A-Z
        elif c >= 48 and c <= 57:  out.append(readNumber(&p))   # 0-9
        elif c == 34 or c == 39: out.append(readString(&p)) # ' and "
        elif c == 95: out.append(readBareword(&p)) # '_'
        elif c == 46 or c == 43 or c == 45: out.append(readNumber(&p)) # . + -
        else:
            token = Token()
            token.type_ = c
            out.append(token)
            if c == 0: return out
            p += 1

cdef class Pyob:
    cdef public str name
    cdef public list ordered
    cdef public dict keyed
    cdef public char reprMode
    def __init__(self,name,ordered=None,keyed=None):
        out.name = name
        if ordered is None: ordered = []
        if keyed is None: keyed = {}
        out.ordered = ordered 
        out.keyed = keyed
    def __repr__(self):
        if self.reprMode == 0:
            return "Pyob(%r,%r,%r)" % (self.name,self.ordered,self.keyed)
        elif self.reprMode == 1:
            oPart = ",".join([repr(x) for x in self.ordered])
            keys = sorted(self.keyed.keys())
            kPart = ",".join(["%s=%r" % (k,self.keyed[k]) for k in keys])
            if oPart and kPart:
                return "%s(%s,%s)" % (self.name,oPart,kPart) 
            elif oPart or kPart:
                return "%s(%s)" % (self.name,oPart or kPart)
            else:
                return "%s()" % self.name
    def __richcmp__(self,other,op):
        if op == 2:
            if not isinstance(other,Pyob): return False
            if self.name != other.name: return False
            if self.ordered != other.ordered: return False
            if self.keyed != other.keyed: return False
            return True
        raise Exception("op not supprted:%s" % op)
    def __getitem__(self,key):
        if isinstance(key,int): return self.ordered[key]
        if isinstance(key,str): return self.keyed[key]
        if key is None: return self.name
    def __setitem__(self,key,value):
        if isinstance(key,int): 
            while key > len(self.ordered) - 1:
                self.ordered.append(None)
            self.ordered[key] = value
        if isinstance(key,str): self.keyed[key] = value
        if key is None: self.name = value
    def __contains__(self,thing):
        return thing in self.keyed

cdef class Parser:
    cdef list tokens
    cdef int i
    cdef int n
    cdef readDict(Parser self):
        out = dict()
        cdef Token token
        while True:
            if self.i >= self.n: raise Exception("no }?")
            token = <Token> self.tokens[self.i]
            if token.type_ == CLOSE_CURLY:
                self.i += 1
                return out
            elif token.type_ == CLOSE_PAREN or token.type_ == CLOSE_BRACKET:
                raise Exception("mismatched [")
            elif token.type_ == COMMA:
                self.i += 1
            else:
                key = self.readValue()
                token = <Token> self.tokens[self.i]
                if token.type_ != COLON: raise Exception("bad dict?")
                self.i += 1
                value = self.readValue()
                out[key] = value
    cdef readList(Parser self):
        out = list()
        cdef Token token
        while True:
            if self.i >= self.n: raise Exception("no ]?")
            token = <Token> self.tokens[self.i]
            if token.type_ == CLOSE_BRACKET:
                self.i += 1
                return out
            elif token.type_ == COMMA:
                self.i += 1
            elif token.type_ == CLOSE_PAREN or token.type_ == CLOSE_BRACKET:
                raise Exception("mismatched [")
            else:
                out.append( self.readValue() )
    cdef readPyob(Parser self,str name):
        out = Pyob(name)
        cdef Token token
        cdef Token t2
        cdef Token t3
        while True:
            if self.i >= self.n: raise Exception("no )?")
            token = <Token> self.tokens[self.i]
            if token.type_ == CLOSE_PAREN:
                self.i += 1
                return out
            elif token.type_ == CLOSE_CURLY or token.type_ == CLOSE_BRACKET:
                raise Exception("mismatched (")
            elif token.type_ == COMMA:
                self.i += 1
            else:
                if token.type_ == BAREWORD and self.i + 2 < self.n:
                    t2 = <Token> self.tokens[self.i+1]
                    if t2.type_ == EQ_SIGN:
                        self.i += 2
                        value = self.readValue()
                        out.keyed[token.value_] = value
                else:
                    out.ordered.append( self.readValue() )
    cdef readValue(Parser self):
        if self.i >= self.n: raise Exception("out of tokens?")
        cdef Token token = <Token> self.tokens[self.i]
        cdef Token t2
        self.i += 1
        if token.type_ == QUOTED: return token.value_
        if token.type_ == NUMBER: return token.value_
        if token.type_ == BAREWORD:
            if self.i < self.n:
                t2 = <Token> self.tokens[self.i]
                if t2.type_ == OPEN_PAREN:
                    self.i += 1
                    return self.readPyob(token.value_)
            if token.value_.lower() == "true": return True
            if token.value_.lower() == "false": return False
            if token.value_.lower() == "none": return None
            if token.value_.lower() == "null": return None
            raise Exception("bad bareword:" + token.value_)
        if token.type_ == OPEN_BRACKET: return self.readList()
        if token.type_ == OPEN_CURLY: return self.readDict()
        raise Exception("don't know how to parse: %r" % token)
    cpdef parse(Parser self,char* zstring):
        self.tokens = tokenize(zstring)
        self.i = 0
        self.n = len(self.tokens)
        return self.readValue()

