
cpdef tokenize(char* zstring):
    cdef list out = list()
    cdef char c 
    cdef char* p = zstring
    cdef Token token
    while True:
        c = p[0]
        if c == 32 or c == 9 or c == 10: p += 1 # whitespace
        elif c == 35 or c == 47: readComment(&p)
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

