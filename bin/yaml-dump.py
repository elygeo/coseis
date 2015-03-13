#!/usr/bin/env python
"""
Dump YAML or JSON file in YAML format
"""

if __name__ != '__main__':
    raise Exception('Not a module')

import sys, yaml

for f in sys.argv[1:]:
    d = yaml.load(open(f))
    d = yaml.dump(d)
    print(d)

