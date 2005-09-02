#!/bin/bash -e
#------------------------------------------------------------------------------#
# PML test script

[ -x sord ]
mkdir pmltest1
mkdir pmltest2
mkdir pmltest3

# Reflecting case
cat << END > in
  hypocenter	21 21 21
  grid		constant
  msrcradius	150.
  viscosity	.0 .3
  domp		.028
  domp		.057
  srctimefcn	sbrune
  moment	1e16 1e16 1e16   0. 0. 0.
  npml		10
  nrmdim	0
  out v		1   0 0 0   31 31 31
  n		41 41 41   120
  bc		1 1 1   0 0 0
END
./sord
mv out meta pmltest1

# Absorbing case
cat << END >> in
  bc           1 1 1   1 1 1
END
./sord
mv out meta pmltest2

# Large case
cat << END >> in
  n            61 61 61   120
END
./sord
mv out meta pmltest3


