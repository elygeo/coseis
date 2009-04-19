#!/bin/bash

#gfortran -Wall -std=f95 -pedantic -fbounds-check -ffpe-trap=invalid,zero,overflow -g rspectra.f90 rspectra-test.f90

#f2py -c --debug --debug-capi --f90flags='-Wall -std=f95 -pedantic -fbounds-check -ffpe-trap=invalid,zero,overflow -g' -m rspectra rspectra.f90

f2py -c -m rspectra rspectra.f90

