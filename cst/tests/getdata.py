#!/usr/bin/env python

import cst.cvms, cst.cvmh, cst.cfm, cst.data

cst.cvms.make()
cst.cvmh.cvmh_voxet()
cst.cfm.catalog()
cst.data.mapdata()
cst.data.etopo1()
cst.data.globe30()
cst.data.lsh_cat()
cst.data.engdahl_cat()

