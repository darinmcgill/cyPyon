from cyPyon import Pyob

def testAssert():
    try:
        assert False
    except:
        print "ok"
        return
    raise Exception("assertions not enabled?")

def testPyob():
    po = Pyob('george')
    assert repr(po) == "Pyob('george',[],{})",repr(po)
    po.reprMode = 1
    assert repr(po) == 'george()',repr(po)
    print "ok"

if __name__ == "__main__":
    for key in dir():
       if key.startswith("test"):
            print key,
            try: eval("%s()" % key)
            except Exception as e: 
                print "failed",e

             
