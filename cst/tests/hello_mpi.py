#!/usr/bin/env python

def build():
    import os, subprocess
    import cst
    cwd = os.getcwd()
    os.chdir(os.path.dirname(__file__))
    d = cst.util.configure()
    m = open('hello_mpi.mk.in').read().format(**d)
    open('hello_mpi.mk', 'w').write(m)
    subprocess.check_call(['make', '-f', 'hello_mpi.mk'])
    os.chdir(cwd)
    return

def test(argv=[]):
    import os
    import cst
    build()
    f = os.path.dirname(__file__)
    f = os.path.join(f, 'hello_mpi.x')
    cst.util.launch(
        name = 'hello_mpi',
        command = './hello_mpi.x',
        stagein = [f],
        run = 'exec',
        argv = argv,
        nproc = 2,
        force = True,
        minutes = 10,
    )
    return

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

