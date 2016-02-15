#!/usr/bin/env python

if __name__ != '__main__':
    raise Exception('not a module')

import pprint
import cst.util

cfg = cst.util.configure()
pprint.pprint(cfg)

