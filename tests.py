#!/usr/bin/env python
from __future__ import print_function
#cyPyon = __import__('cyPyon', globals(), locals(), [], -1)
import cyPyon


def test_assert():
    if cyPyon:
        try:
            assert False
        except Exception:
            print("ok")
            return
    raise Exception("assertions not enabled?")


def test_pyob():
    po = cyPyon.Pyob('george')
    po.reprMode = 0
    assert repr(po) == "Pyob(u'george',[],{})", repr(po)
    po.reprMode = 1
    assert repr(po) == 'george()', repr(po)
    print("ok")


def one_token_test(string, expected):
    out = cyPyon.tokenize(string)
    assert len(out) == 2, (string, out)
    assert repr(out[0]) == expected, (repr(out[0]), expected)


def test_tokenize_int():
    one_token_test(b"3", "Number(3)")
    one_token_test(b"33", "Number(33)")
    one_token_test(b"-3", "Number(-3)")
    one_token_test(b"+5709", "Number(5709)")
    print("ok")


def test_tokenize_float():
    one_token_test(b"3.3", "Number(3.3)")
    one_token_test(b"-3.3", "Number(-3.3)")
    one_token_test(b"-.25", "Number(-0.25)")
    one_token_test(b"-.25e2", "Number(-25.0)")
    one_token_test(b"25e-2", "Number(0.25)")
    print("ok")


def test_tokenize_syntax():
    one_token_test(b":", "Syntax(b':')")
    one_token_test(b",", "Syntax(b',')")
    print("ok")


def test_tokenize_seq():
    string = b"[1,2 3]  ="
    out = cyPyon.tokenize(string)
    s = list(map(str, out))
    assert s == ["Syntax(b'[')", 'Number(1)', "Syntax(b',')",
                 'Number(2)', 'Number(3)', "Syntax(b']')", "Syntax(b'=')", 'End()'], s


def test_tokenize_bareword():
    one_token_test(b"a", "Bareword(u'a')")
    one_token_test(b"ab", "Bareword(u'ab')")
    print("ok")


def test_tokenize_string():
    one_token_test(b"''", "Quoted(u'')")
    one_token_test(b"'a'", "Quoted(u'a')")
    one_token_test(b"'ab'", "Quoted(u'ab')")
    print("ok")


def test_tokenize_all():
    string = b"[1,foo 'bar'=3.25"
    out = cyPyon.tokenize(string)
    s = list(map(str, out))
    assert s == ["Syntax(b'[')", 'Number(1)', "Syntax(b',')", "Bareword(u'foo')",
                 "Quoted(u'bar')", "Syntax(b'=')", 'Number(3.25)', 'End()'], s
    print("ok")


def test_parse_scalar():
    parser = cyPyon.Parser()
    out = parser.parse(b"3")
    assert out == 3, out
    out = parser.parse(b"'foo'")
    assert out == 'foo', out
    out = parser.parse(b"True")
    assert out is True, out
    out = parser.parse(b"None")
    assert out is None, out
    print("ok")


def test_parse_array():
    parser = cyPyon.Parser()
    out = parser.parse(b"[]")
    assert out == [], out
    out = parser.parse(b"[1]")
    assert out == [1], out
    out = parser.parse(b"[1,'foo']")
    assert out == [1, 'foo'], out
    out = parser.parse(b"[[None,'bar'],1]")
    assert out == [[None, 'bar'], 1], out
    print("ok")


def test_parse_dict():
    parser = cyPyon.Parser()
    out = parser.parse(b"{}")
    assert out == {}, out
    out = parser.parse(b"{1:3}")
    assert out == {1: 3}, out
    out = parser.parse(b"{1:'foo','bar':19}")
    assert out == {1: 'foo', 'bar': 19}, out
    out = parser.parse(b"{1:[0],3:{7:9}}")
    assert out == {1: [0], 3: {7: 9}}, out
    print("ok")


def test_parser_pyob():
    parser = cyPyon.Parser()
    out = parser.parse(b"A()")
    assert out == cyPyon.Pyob('A'), out
    out = parser.parse(b"Ab(9)")
    assert out == cyPyon.Pyob('Ab', [9]), out
    out = parser.parse(b"Ab(9,10,foo=3)")
    assert out == cyPyon.Pyob('Ab', [9, 10], {'foo': 3}), out
    print("ok")


def test_parser_pyob_unicode():
    parser = cyPyon.Parser()
    out = parser.parse(u"A()")
    assert out == cyPyon.Pyob('A'), out
    out = parser.parse(u"Ab(9)")
    assert out == cyPyon.Pyob('Ab', [9]), out
    out = parser.parse(u"Ab(9,10,foo=3)")
    assert out == cyPyon.Pyob('Ab', [9, 10], {'foo': 3}), out
    print("ok")


def test_pyon_compare():
    parser = cyPyon.Parser()
    _ = """
    class Ab:
        def __init__(self,*a,**b): pass
    out1 = eval(x)  # type: Ab
    """
    x = b"Ab([92],foo={3:12},bar=None)"
    out2 = parser.parse(x)
    assert out2 == cyPyon.Pyob('Ab', [[92]], {'foo': {3: 12}, 'bar': None}), out2
    print("ok")


def test_pyob_repr_mode():
    p = cyPyon.Pyob("foo")
    p["bar"] = 3
    p[0] = "cheese"
    p.reprMode = 1
    assert repr(p) == "foo('cheese',bar=3)", repr(p)
    print("ok")


def test_parse_int():
    p = cyPyon.Parser()
    out = p.parse(b"42")
    assert repr(out) == '42', repr(out)
    print("ok")


def test_issue1():
    x = b"[13505, 'newStratRunner', 'RKAYITKU', 'prod', 'GC^', w(s(asks=1,bids=1),em=0,exTpv=2," + \
        b"pnl=0.0,pos=0,ppc=0.0," + \
        b"res='GCG3',vlm=0)] "
    p = cyPyon.Parser()
    out = p.parse(x)
    assert out
    print("ok")


def test_issue2():
    x = b"[17926, 'bridgeCme', 'FGGJTXDY', t(_pnl=-13.48,_pos={},closed=-12.5,eS={'ESH3': 2},eV={'ESH3': 2}," + \
        b"fees=0.98,open=0.0,slb=-500)]"
    p = cyPyon.Parser()
    out = p.parse(x)
    assert out
    print("ok")


def test_parse_func():
    x = b"[17926, 'bridgeCme', 'FGGJTXDY', t(_pnl=-13.48,_pos={},closed=-12.5,eS={'ESH3': 2}," + \
        b"eV={'ESH3': 2},fees=0.98,open=0.0,slb=-500)]"
    out = cyPyon.parse(x)
    assert out[1] == "bridgeCme", out
    print("ok")


def test_pickle():
    import pickle
    x = cyPyon.Pyob('a', ['foo', 3], dict(bar=99))
    y = pickle.loads(pickle.dumps(x))
    assert x == y, (x, y)
    assert x is not y
    assert repr(y) == "a('foo',3,bar=99)", repr(y)
    print("ok")


def test_comments():
    x = b"[17926,  #cheese\n3, /* nevermind */7]"
    out = cyPyon.parse(x)
    assert out[1] == 3, out
    assert out[2] == 7, out
    print("ok")


if __name__ == "__main__":
    import sys
    if sys.argv[1:]:
        eval("%s()" % sys.argv[1])
        sys.exit(0)
    failed = list()
    for key in dir():
        if key.startswith("test"):
            print(key, end=" ")
            try:
                eval("%s()" % key)
            except Exception as e: 
                failed.append(key)
                print("failed", e)
    print("failed:", failed)
