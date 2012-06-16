#!/usr/bin/env python

def build():
    import os, shlex
    import cst
    f = os.path.dirname(__file__)
    f = os.path.join(f, 'hello_mpi')
    s = f + '.f90'
    o = f + '.x'
    job = cst.util.configure()
    c  = shlex.split(job.compiler_f)
    c += shlex.split(job.compiler_opts['f']) + [s]
    c += shlex.split(job.compiler_opts['O'])
    cst.util.make(c, [o], [s])
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
    build()
    test(sys.argv[1:])

