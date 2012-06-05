import os, glob

exclude = 'ws-meta-in.py',
include = (
    'setup.py',
    'bin/*.py',
    'cst/*.py',
    'cst/sord/*.py',
    'cst/cvms/*.py',
    'cst/conf/*.py',
    'cst/tests/*.py',
    'doc/*.py',
    'scripts/*/*.py',
)

def test_syntax():
    """
    Test code syntax.
    """
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
    test_syntax()

