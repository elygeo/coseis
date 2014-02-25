#!/usr/bin/env python

def test(**kwargs):
    import doctest
    import cst.tests
    failed = []
    for m in [
        cst.coord,
        cst.sord,
    ]:
        c = 'doctest.testmod(%s)' % m.__name__
        print('-' * 80)
        print('>>> ' + c)
        f, t = doctest.testmod(m)
        if f:
            failed.append(c)
    assert(failed == [])

if __name__ == "__main__":
    test()

