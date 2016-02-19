#!/usr/bin/env python3
"""Test code syntax."""
import os


def test(**kwargs):
    for p, d, ff in os.walk('..'):
        for f in ff:
            if f[-3:] != '.py':
                continue
            f = os.path.join(p, f)
            c = open(f).read()
            compile(c, f, 'exec')

if __name__ == '__main__':
    test()
