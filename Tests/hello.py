#!/usr/bin/env python
import os
import shutil
import subprocess
from cst import conf


def make():
    cwd = os.getcwd()
    cfg = conf.configure()
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
    cwd = os.getcwd()
    path = os.path.dirname(__file__) + os.sep
    path = os.path.realpath(path)
    make()

    d = os.path.join('run', 'hello-c')
    f = os.path.join(path, 'hello.c.x')
    os.makedirs(d)
    os.chdir(d)
    shutil.copy2(f, '.')
    conf.launch(
        executable='./hello.c.x',
        nthread=2,
        nproc=2,
        ppn_range=[2],
        minutes=10,
        **kwargs
    )
    os.chdir(cwd)

    d = os.path.join('run', 'hello-f')
    f = os.path.join(path, 'hello.f.x')
    os.makedirs(d)
    os.chdir(d)
    shutil.copy2(f, '.')
    conf.launch(
        executable='./hello.f.x',
        nthread=2,
        nproc=2,
        ppn_range=[2],
        minutes=10,
        **kwargs
    )
    os.chdir(cwd)

    return

if __name__ == '__main__':
    test()
