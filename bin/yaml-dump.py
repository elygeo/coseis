#!/usr/bin/env python
"""
Dump YAML or JSON file in YAML format
"""

if __name__ != '__main__':
    raise Exception('Not a module')

import sys, yaml

if len(sys.argv) == 1:
    d = yaml.load(sys.stdin)
    d = yaml.dump(d, width=64, allow_unicode=True)
    print(d)
else:
    for f in sys.argv[1:]:
        d = yaml.load(open(f))
        d = yaml.dump(d, width=64, allow_unicode=True)
        print(d)


