#!/usr/bin/env python

exclude = 'ws-meta-in.py',
include = (
    'setup.py',
    'bin/*',
    'doc/*.py',
    'cst/*.py',
    'cst/*/*.py',
    'scripts/*/*.py',
)

def test():
    """
    Test code syntax.
    """
    import os, glob
    cwd = os.getcwd()
    top = os.path.join(os.path.dirname(__file__), '..', '..')
    os.chdir(top)
    for p in include:
        for f in glob.glob(p):
            if os.path.basename(f) in exclude:
                continue
            c = open(f, 'U').read()
            compile(c, f, 'exec')
    os.chdir(cwd)
    return

# continue if command line
if __name__ == '__main__':
    test()

