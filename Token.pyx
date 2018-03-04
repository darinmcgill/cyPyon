
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
        if self.type_ == END:
            return "End()"
        if self.type_ == BAREWORD:
            return "Bareword(u'%s')" % self.value_
        if self.type_ == NUMBER: 
            if isinstance(self.value_,float):
                return "Number(%r)" % self.value_
            else:
                return "Number(%r)" % int(self.value_)
        if self.type_ == QUOTED:
            return "Quoted(u'%s')" % self.value_
        return "Syntax(b'%s')" % chr(self.type_)

    def __richcmp__(self,other,op):
        cdef Token other_token
        if op == 2: 
            if not isinstance(other, Token):
                return False
            other_token = <Token> other
            if other_token.type_ != self.type_:
                return False
            if other_token.value_ != self.value_:
                return False
            return True
        else:
            raise Exception("operation not supported: %s" % op)
            
