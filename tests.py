#!/usr/bin/env python
from cyPyon import *

def testAssert():
    try:
        assert False
    except:
        print "ok"
        return
    raise Exception("assertions not enabled?")

def testPyob():
    po = Pyob('george')
    po.reprMode = 0
    assert repr(po) == "Pyob('george',[],{})",repr(po)
    po.reprMode = 1
    assert repr(po) == 'george()',repr(po)
    print "ok"

def oneTokenTest(string,expected):
    out = tokenize(string)
    assert len(out) == 2, (string,out)
    assert repr(out[0]) == expected, (repr(out[0]),expected)

def testTokenizeInt():
    oneTokenTest("3","Number(3)")
    oneTokenTest("33","Number(33)")
    oneTokenTest("-3","Number(-3)")
    oneTokenTest("+5709","Number(5709)")
    print "ok"

def testTokenizeFloat():
    oneTokenTest("3.3","Number(3.3)")
    oneTokenTest("-3.3","Number(-3.3)")
    oneTokenTest("-.25","Number(-0.25)")
    oneTokenTest("-.25e2","Number(-25.0)")
    oneTokenTest("25e-2","Number(0.25)")
    print "ok"

def testTokenizeSyntax():
    oneTokenTest(":","Syntax(':')")
    oneTokenTest(",","Syntax(',')")
    print "ok"

def testTokenizeSeq():
    string = "[1,2 3]  ="
    out = tokenize(string)
    s = map(str,out)
    assert s ==  ["Syntax('[')", 'Number(1)', "Syntax(',')", 
        'Number(2)', 'Number(3)', "Syntax(']')", "Syntax('=')", 'End()'],s

def testTokenizeBareword():
    oneTokenTest("a","Bareword('a')")
    oneTokenTest("ab","Bareword('ab')")
    print "ok"

def testTokenizeString():
    oneTokenTest("''","Quoted('')")
    oneTokenTest("'a'","Quoted('a')")
    oneTokenTest("'ab'","Quoted('ab')")
    print "ok"

def testTokenizeAll():
    string = "[1,foo 'bar'=3.25"
    out = tokenize(string)
    s = map(str,out)
    assert s == ["Syntax('[')", 'Number(1)', "Syntax(',')", "Bareword('foo')", 
        "Quoted('bar')", "Syntax('=')", 'Number(3.25)', 'End()'], s
    print "ok"

def testParseScalar():
    parser = Parser()
    out = parser.parse("3")
    assert out == 3,out
    out = parser.parse("'foo'")
    assert out == 'foo',out
    out = parser.parse("True")
    assert out == True,out
    out = parser.parse("None")
    assert out == None,out
    print "ok"

def testParseArray():
    parser = Parser()
    out = parser.parse("[]")
    assert out == [],out
    out = parser.parse("[1]")
    assert out == [1],out
    out = parser.parse("[1,'foo']")
    assert out == [1,'foo'],out
    out = parser.parse("[[None,'bar'],1]")
    assert out == [[None,'bar'],1],out
    print "ok"

def testParseDict():
    parser = Parser()
    out = parser.parse("{}")
    assert out == {},out
    out = parser.parse("{1:3}")
    assert out == {1:3},out
    out = parser.parse("{1:'foo','bar':19}")
    assert out == {1:'foo','bar':19},out
    out = parser.parse("{1:[0],3:{7:9}}")
    assert out == {1:[0],3:{7:9}},out
    print "ok"

def testParsePyob():
    parser = Parser()
    out = parser.parse("A()")
    assert out == Pyob('A'),out
    out = parser.parse("Ab(9)")
    assert out == Pyob('Ab',[9]),out
    out = parser.parse("Ab(9,10,foo=3)")
    assert out == Pyob('Ab',[9,10],{'foo':3}),out
    print "ok"

def testPyonCompare():
    parser = Parser()
    class Ab:
        def __init__(self,*a,**b): pass
    x = "Ab([92],foo={3:12},bar=None)"
    out = eval(x)
    out = parser.parse(x)
    assert out == Pyob('Ab',[[92]],{'foo':{3:12},'bar':None}),out
    print "ok"

def testPyobReprMode():
    p = Pyob("foo")
    p["bar"] = 3
    p[0] = "cheese"
    p.reprMode = 1
    assert repr(p) == "foo('cheese',bar=3)",repr(p)
    print "ok"

def testParseInt():
    p = Parser()
    out = p.parse("42")
    assert repr(out) == '42',repr(out)
    print "ok"

def testIssue1():
    x = " [13505, 'newStratRunner', 'RKAYITKU', 'prod', 'GC^', w(s(asks=1,bids=1),em=0,exTpv=2,pnl=0.0,pos=0,ppc=0.0,res='GCG3',vlm=0)] "
    p = Parser()
    out = p.parse(x)
    print "ok"

def testIssue2():
    x = "[17926, 'bridgeCme', 'FGGJTXDY', t(_pnl=-13.48,_pos={},closed=-12.5,eS={'ESH3': 2},eV={'ESH3': 2},fees=0.98,open=0.0,slb=-500)]"
    p = Parser()
    out = p.parse(x)
    print "ok"

def testParseFunc():
    x = "[17926, 'bridgeCme', 'FGGJTXDY', t(_pnl=-13.48,_pos={},closed=-12.5,eS={'ESH3': 2},eV={'ESH3': 2},fees=0.98,open=0.0,slb=-500)]"
    out = parse(x)
    assert out[1] == "bridgeCme",out
    print "ok"

def testPickle():
    import pickle
    x = Pyob('a',['foo',3],dict(bar=99))
    y = pickle.loads(pickle.dumps(x))
    assert x == y,(x,y)
    assert x is not y
    assert repr(y) == "a('foo',3,bar=99)",repr(y)

def testComments():
    x = "[17926,  #cheese\n3, /* nevermind */7]"
    out = parse(x)
    assert out[1] == 3,out
    assert out[2] == 7,out
    print "ok"
    
if __name__ == "__main__":
    failed = list()
    for key in dir():
       if key.startswith("test"):
            print key,
            try: eval("%s()" % key)
            except Exception as e: 
                failed.append(key)
                print "failed",e
    print "failed:",failed

             
