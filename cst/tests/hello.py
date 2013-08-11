#!/usr/bin/env python

def make():
    import os, subprocess
    import cst
    cwd = os.getcwd()
    cfg = cst.util.configure()
    path = os.path.dirname(__file__)
    os.chdir(path)
    if cfg['force'] or not os.path.exists('Makefile'):
        m = open('Makefile.in').read().format(**cfg)
        open('Makefile', 'w').write(m)
    subprocess.check_call(['make'])
    os.chdir(cwd)
    return

def test(argv=[]):
    import os, shutil
    import cst
    cwd = os.getcwd()
    path = os.path.dirname(__file__) + os.sep
    make()

    # C version
    d = os.path.join('run', 'hello-c')
    os.makedirs(d)
    shutil.copy2(path + 'hello.c.x', d)
    os.chdir(d)
    cst.util.launch(
        run = 'exec',
        argv = argv,
        command = './hello.c.x',
        nthread = 2,
        nproc = 2,
        ppn_range = [2],
        minutes = 10,
    )
    os.chdir(cwd)

    # Fortran version
    d = os.path.join('run', 'hello-f')
    os.makedirs(d)
    shutil.copy2(path + 'hello.f.x', d)
    os.chdir(d)
    cst.util.launch(
        run = 'exec',
        argv = argv,
        command = './hello.f.x',
        nthread = 2,
        nproc = 2,
        ppn_range = [2],
        minutes = 10,
    )
    os.chdir(cwd)

    return

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

