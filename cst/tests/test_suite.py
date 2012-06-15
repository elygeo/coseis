#!/usr/bin/env python

def test():
    import os, doctest
    import cst.tests

    passed = []
    failed = []

    # doc tests
    for m in [
        cst.util,
        cst.coord,
        cst.sord,
    ]:
        c = 'doctest.testmod(%s)' % m.__name__
        print('-' * 80)
        print('>>> ' + c)
        f, t = doctest.testmod(m)
        if f:
            failed.append('FAILED: ' + c)
        elif t:
            passed.append('PASSED: ' + c)

    # unit tests
    path = os.path.dirname(cst.tests.__file__)
    for m in [
        cst.tests.syntax,
        cst.tests.configure,
        cst.tests.hello_mpi,
        cst.tests.point_source,
        cst.tests.pml_boundary,
        cst.tests.kostrov,
    ]:
        os.chdir(path)
        c = '%s.test()' % m.__name__
        print('-' * 80)
        print('>>> ' + c)
        try:
            m.test()
            passed.append('PASSED: ' + c)
        except Exception as e:
            failed.append('FAILED: %s: %s' % (c, e.message))

    # report
    print('\n' + '\n'.join(passed))
    print('\n' + '\n'.join(failed))

if __name__ == "__main__":
    test()

