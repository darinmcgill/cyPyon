

cdef readNumber(char **stringPtr):
    cdef char* p = stringPtr[0]
    cdef signed char sign = 1
    if p[0] == 45: 
        sign = -1 # '-'
        p += 1
    if p[0] == 43: p += 1 # '+'
    cdef char floating = 0
    cdef long beforeDecimal = 0
    cdef double afterDecimal = 0.0
    cdef int e = 0
    cdef signed char eSign = +1 
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

cdef readComment(char **stringPtr):
    if stringPtr[0][0] == 35:
        stringPtr[0] += 1
        while stringPtr[0][0] != 10 and stringPtr[0][0] != 0:
            stringPtr[0] += 1
        return 
    if stringPtr[0][0] == 47 and stringPtr[0][1] == 47:
        stringPtr[0] += 2
        while stringPtr[0][0] != 10 and stringPtr[0][0] != 0:
            stringPtr[0] += 1
        return 
    if stringPtr[0][0] == 47 and stringPtr[0][1] == 42:
        stringPtr[0] += 2
        while stringPtr[0][0] != 0:
            if stringPtr[0][0] == 42 and stringPtr[0][1] == 47:
                stringPtr[0] += 2
                return
            stringPtr[0] += 1
        return 
