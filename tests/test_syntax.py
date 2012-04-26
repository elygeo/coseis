#!/usr/bin/env python
"""
Code tests
"""
import os, compiler

def test_imports():
    """
    Test imports
    """
    import cst

def test_syntax():
    """
    Test code syntax
    """
    exclude = 'ws-meta-in.py',
    cwd = os.getcwd()
    top = os.path.join(os.path.dirname(__file__), '..')
    os.chdir(top)
    for path in 'cst', 'scripts', 'bin', 'doc', 'tests':
        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:
                if filename.endswith('.py') and filename not in exclude:
                    filename = os.path.join(dirpath, filename)
                    code = open(filename, 'U').read()
                    compile(code, filename, 'exec')
    os.chdir(cwd)
    return

def test_with_pyflakes():
    """
    Test code with Pyflakes. FIXME: currently Pyflakes seems broken.
    """
    return
    import pyflakes.checker
    exclude = 'ws-meta-in.py',
    cwd = os.getcwd()
    top = os.path.join(os.path.dirname(__file__), '..')
    os.chdir(top)
    messages = []
    for path in 'scripts', 'bin', 'doc':
        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:
                if filename.endswith('.py') and filename not in exclude:
                    filename = os.path.join(dirpath, filename)
                    print filename
                    code = open(filename, 'U').read()
                    compile(code, filename, 'exec')
                    tree = compiler.parse(code)
                    checker = pyflakes.checker.Checker(tree, filename)
                    for m in checker.messages:
                        if (not m.filename.endswith('__init__.py')
                            or m.message != '%r imported but unused'):
                            messages += [m]
                            print m
    os.chdir(cwd)
    assert messages == []
    return

# continue if command line
if __name__ == '__main__':
    test_imports()
    test_syntax()
    test_with_pyflakes()

