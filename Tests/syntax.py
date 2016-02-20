"""
Test code syntax.
Run this with python2 and python3
"""
import os


def test(**kwargs):
    for p, d, ff in os.walk('..'):
        for f in ff:
            if f[-3:] != '.py':
                continue
            f = os.path.join(p, f)
            c = open(f).read()
            try:
                compile(c, f, 'exec')
            except SyntaxError as e:
                print(e)

if __name__ == '__main__':
    test()
