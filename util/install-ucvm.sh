#!/bin/bash

# install prefix
cd "${1:-.}"
prefix="${PWD}/ucvm"
mkdir "${prefix}"

# PROJ.4 Library
cd "${prefix}"
url="http://download.osgeo.org/proj/proj-4.8.0.tar.gz"
proj4="${prefix}/$( basename "$url" .tar.gz )"
curl -L "${url}" | tar zx
cd "${proj4}"
./configure
make install

# CMU Euclid Etree Library
cd "${prefix}"
url="http://hypocenter.usc.edu/research/ucvm/12.2.0/euclid3-1.3.tar.gz"
etree="${prefix}/$( basename "$url" .tar.gz )/libsrc"
curl -L "${url}" | tar zx
cd "${etree}"
make

# CVM-H
cd "${prefix}"
url="http://hypocenter.usc.edu/research/ucvm/models/cvmh-11.9.0.tar.gz"
cvmh="${prefix}/$( basename "$url" .tar.gz )"
curl -L "${url}" | tar zx
cd "${cvmh}"
./configure
make install

# UCVM
cd "${prefix}"
url="http://hypocenter.usc.edu/research/ucvm/12.2.0/ucvm-12.2.0.tar.gz"
tag="$( basename "$url" .tar.gz )"
curl -L "${url}" | tar zx
cd "${tag}"
./configure --prefix=${prefix} 
  --with-proj4-include-path="${proj4}/include" 
  --with-proj4-lib-path="${proj4}/lib"
  --with-etree-include-path="${etree}" 
  --with-etree-lib-path="${etree}" 
  --with-gctpc-lib-path="${cvmh}/gctpc/lib"
  --with-cvmh-include-path="${cvmh}/include" 
  --with-cvmh-lib-path="${cvmh}/lib" 
  --with-cvmh-model-path="${cvmh}/bin"
make check
make install

