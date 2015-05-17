
cdef class Parser:

    cdef list tokens
    cdef int i # token index
    cdef int n # number of tokens
    cdef int j # sanity counter
    cdef int m # number of characters
    cdef bytes toParse

    cdef readDict(Parser self):
        out = dict()
        cdef Token token
        while True:
            self.j += 1
            if self.j > self.m: 
                raise Exception("WXNABBCFCA\n%s" % self.toParse)
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
            self.j += 1
            if self.j > self.m: 
                raise Exception("MRDKZDUXVS\n%s" % self.toParse)
            if self.i >= self.n: raise Exception("no ]?")
            token = <Token> self.tokens[self.i]
            if token.type_ == CLOSE_BRACKET:
                self.i += 1
                return out
            elif token.type_ == COMMA:
                self.i += 1
            elif token.type_ == CLOSE_PAREN or token.type_ == CLOSE_CURLY:
                raise Exception("mismatched [")
            else:
                out.append( self.readValue() )

    cdef readPyob(Parser self,str name):
        out = Pyob(name)
        cdef Token token
        cdef Token t2
        cdef Token t3
        while True:
            self.j += 1
            if self.j > self.m: 
                raise Exception("OHWYBQMBOY\n%s" % self.toParse)
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
            if token.value_.lower() == "nan": return float('nan')
            if token.value_.lower() == "inf": return float('inf')
            raise Exception("bad bareword:" + token.value_)
        if token.type_ == OPEN_BRACKET: return self.readList()
        if token.type_ == OPEN_CURLY: return self.readDict()
        raise Exception("don't know how to parse: %r" % token)

    def parse(Parser self, toParse):
        self.toParse = toParse
        self.tokens = tokenize(toParse)
        self.j = 0
        self.i = 0
        self.n = len(self.tokens)
        self.m = len(self.toParse)
        return self.readValue()

def parse(thing):
    parser = Parser()
    return parser.parse(thing)
