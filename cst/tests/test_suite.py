#!/usr/bin/env python

def test():
    import os, imp, doctest
    import cst
    d = os.path.dirname(cst.__file__)
    d = os.path.join(d, 'tests')
    os.chdir(d)
    passed = []
    failed = []
    for m in [
        cst.util,
        cst.coord,
        cst.sord,
        'syntax',
        'conf',
        'hello_mpi',
        'sord_point',
        'sord_pml',
        'sord_kostrov',
    ]:
        # import test
        if isinstance(m, basestring):
            msg = 'import ' + m
            try:
                m = imp.load_source(m, m + '.py')
            except Exception as e:
                failed.append('FAILED: %s: %s' % (msg, e.message))
                continue
        name = m.__name__

        # unit test
        if hasattr(m, 'test'):
            msg = name + '.test()'
            try:
                m.test()
            except Exception as e:
                failed.append('FAILED: %s: %s' % (msg, e.message))
            else:
                passed.append('PASSED: ' + msg)

        # doc test
        if m.__doc__:
            msg = 'doctest.testmod(%s)' % name
            f, t = doctest.testmod(m)
            if f:
                failed.append('FAILED: ' + msg)
            elif t:
                passed.append('PASSED: ' + msg)

        print('-' * 80)

    print('\n' + '\n'.join(passed))
    print('\n' + '\n'.join(failed))

if __name__ == "__main__":
    test()

