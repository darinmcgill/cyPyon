cyPyon
======

A Python Object Notation parser written in Cython. 

Example usage:

    from cyPyon import parse
    x = "[17926, 'FGGJTXDY', t(_pnl=-13.48,_pos={},closed=-12.5,eS={'ESH3': 2},eV={'ESH3': 2},fees=0.98)]"
    out = parse(x) # give a list
