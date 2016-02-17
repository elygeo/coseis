#!/usr/bin/env python3

def test(**kwargs):
    import doctest
    from cst import sord, coord
    failed = []
    for m in [coord, sord]:
        c = 'doctest.testmod(%s)' % m.__name__
        print('-' * 80)
        print('>>> ' + c)
        f, t = doctest.testmod(m)
        if f:
            failed.append(c)
    assert(failed == [])

if __name__ == "__main__":
    test()

