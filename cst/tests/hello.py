#!/usr/bin/env python

def make():
    import os, subprocess
    import cst
    cwd = os.getcwd()
    cfg = cst.util.configure()
    path = os.path.dirname(__file__)
    path = os.path.realpath(path)
    os.chdir(path)
    if not os.path.exists('Makefile'):
        m = open('Makefile.in').read().format(**cfg)
        open('Makefile', 'w').write(m)
    subprocess.check_call(['make'])
    os.chdir(cwd)
    return

def test(**kwargs):
    import os, shutil
    import cst
    cwd = os.getcwd()
    path = os.path.dirname(__file__) + os.sep
    path = os.path.realpath(path)
    make()

    # C version
    d = os.path.join('run', 'hello-c')
    f = os.path.join(path, 'hello.c.x')
    os.makedirs(d)
    os.chdir(d)
    shutil.copy2(f, '.')
    cst.util.launch(
        executable = './hello.c.x',
        nthread = 2,
        nproc = 2,
        ppn_range = [2],
        minutes = 10,
        **kwargs
    )
    os.chdir(cwd)

    # Fortran version
    d = os.path.join('run', 'hello-f')
    f = os.path.join(path, 'hello.f.x')
    os.makedirs(d)
    os.chdir(d)
    shutil.copy2(f, '.')
    cst.util.launch(
        executable = './hello.f.x',
        nthread = 2,
        nproc = 2,
        ppn_range = [2],
        minutes = 10,
        **kwargs
    )
    os.chdir(cwd)

    return

# continue if command line
if __name__ == '__main__':
    test()

