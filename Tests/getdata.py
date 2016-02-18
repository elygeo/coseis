#!/usr/bin/env python

from cst import cvms, cvmh, cfm, data

cvms.make()
cvmh.cvmh_voxet()
cfm.catalog()
data.mapdata()
data.etopo1()
data.globe30()
data.lsh_cat()
data.engdahl_cat()
