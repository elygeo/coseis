#!/usr/bin/env python

exclude = []
include = [
    'cst/*.py',
    'cst/*/*.py',
    'Scripts/*.py',
    'Util/*.py',
]

def test(**kwargs):
    """
    Test code syntax.
    """
    import os, glob
    import cst
    path = os.path.dirname(cst.__file__) + '../'
    for p in include:
        for f in glob.glob(path + p):
            if os.path.basename(f) in exclude:
                continue
            c = open(f, 'U').read()
            compile(c, f, 'exec')
    return

# continue if command line
if __name__ == '__main__':
    test()

