#!/bin/bash -e

[ -x sord ]

cat << END > 'in.m'
  faultnormal = 0;
  rsource = 150.;
  nt = 400;
  nn = [ 81 81 81 ];
  ihypo = [ 41 41 41 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 1 ];
  out = { 'x' 1   41 41 61   61 61 61 };
  out = { 'v' 1   41 41 61   61 61 61 };
END
./sord -d
mv out runs/pmltest1

cat << END >> 'in.m'
  nn = [ 121 121 121 ];
END
./sord
mv out runs/pmltest2

