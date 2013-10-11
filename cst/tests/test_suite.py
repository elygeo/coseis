#!/usr/bin/env python

def test():
    import os
    import cst.tests

    passed = []
    failed = []

    # unit tests
    path = os.path.dirname(cst.tests.__file__)
    for m in [
        cst.tests.syntax,
        cst.tests.doctests,
        cst.tests.configure,
        cst.tests.hello,
        cst.tests.sord_mpi,
        cst.tests.sord_pml,
        cst.tests.sord_kostrov,
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

    # finished
    print('\n' + '\n'.join(passed))
    print('\n' + '\n'.join(failed))

if __name__ == "__main__":
    test()

