cdef class Pyob:

    cdef public str name
    cdef public list ordered
    cdef public dict keyed
    cdef public char reprMode

    def __init__(self,name,ordered=None,keyed=None):
        self.name = name
        if ordered is None: ordered = []
        if keyed is None: keyed = {}
        self.ordered = ordered 
        self.keyed = keyed
        self.reprMode = 1

    __safe_for_unpickling__ = True
    def __reduce__(self):
        return (Pyob,(self.name,self.ordered,self.keyed))

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

    def get(self,key,default=None):
        if isinstance(key,str):
            return self.keyed.get(key,default)
        if isinstance(key,int):
            return self.ordered[key] if key < len(self.ordered) else default
        raise Exception("unrecognized key type:%s" % type(key))

    def setdefault(self,key,default):
        if isinstance(key,str):
            return self.keyed.setdefault(key,default)
        raise Exception("not appropriate key for set default:%s" % key)

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
        return thing in self.keyed or thing in self.ordered

    def __nonzero__(self):
        return bool(self.ordered) or bool(self.keyed)

    def __len__(self):
        return len(self.ordered)

    def __iter__(self):
        return iter(self.ordered)
