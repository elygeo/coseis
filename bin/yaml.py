#!/usr/bin/env python
"""
Dump YAML or JSON file in YAML format
"""
import sys, yaml

for f in sys.argv[1:]:
    d = yaml.load(open(f))
    d = yaml.dump(d)
    print(d)
