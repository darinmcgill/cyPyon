include "readers.pyx"

cpdef tokenize(char* zstring):
    cdef list out = list()
    cdef char c 
    cdef char* p = zstring
    cdef Token token
    while True:
        c = p[0]
        if c == 32 or c == 9 or c == 10: p += 1 # whitespace
        elif c == 35 or c == 47: readComment(&p)
        elif 97 <= c <= 122: out.append(read_bareword(&p)) # a-z
        elif 65 <= c <= 90:  out.append(read_bareword(&p)) # A-Z
        elif 48 <= c <= 57:  out.append(readNumber(&p))   # 0-9
        elif c == 34 or c == 39: out.append(readString(&p)) # ' and "
        elif c == 95: out.append(read_bareword(&p)) # '_'
        elif c == 46 or c == 43 or c == 45: out.append(readNumber(&p)) # . + -
        else:
            token = Token()
            token.type_ = c
            out.append(token)
            if c == 0:
                return out
            p += 1

