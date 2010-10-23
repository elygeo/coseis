#!/usr/bin/env python
"""
Tests
"""
import doctest
import cst

for m in cst.util, cst.coord, cst.conf:
    doctest.testmod( m )
    #tests.addTests()
    #doctest.DocTestSuite( m )

