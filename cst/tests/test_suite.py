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
        'configure',
        'hello_mpi',
        'point_source',
        'pml_boundary',
        'kostrov',
    ]:
        # import test
        print('-' * 80)
        if isinstance(m, basestring):
            c = 'import ' + m
            print('>>> ' + c)
            try:
                m = imp.load_source(m, m + '.py')
            except Exception as e:
                failed.append('FAILED: %s: %s' % (c, e.message))
                continue
        name = m.__name__

        # unit test
        if hasattr(m, 'test'):
            c = name + '.test()'
            print('>>> ' + c)
            try:
                m.test()
            except Exception as e:
                failed.append('FAILED: %s: %s' % (c, e.message))
            else:
                passed.append('PASSED: ' + c)

        # doc test
        if m.__doc__:
            c = 'doctest.testmod(%s)' % name
            print('>>> ' + c)
            f, t = doctest.testmod(m)
            if f:
                failed.append('FAILED: ' + c)
            elif t:
                passed.append('PASSED: ' + c)

    print('\n' + '\n'.join(passed))
    print('\n' + '\n'.join(failed))

if __name__ == "__main__":
    test()

