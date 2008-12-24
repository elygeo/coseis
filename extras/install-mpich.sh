#!/bin/bash -e

echo -n "Installing MPICH2 in ${HOME}/local. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

export PATH=${HOME}/local/bin:${PATH}
mkdir -p ${HOME}/local
cd ${HOME}/local

wget http://www.mcs.anl.gov/research/projects/mpich2/downloads/tarballs/1.0.8/mpich2-1.0.8.tar.gz
tar zxvf mpich2-1.0.8.tar.gz
cd mpich2-1.0.8
./configure -prefix=${HOME}/local --with-device=ch3:shm
make
make install

echo "Don't forget to add \${HOME}/local/bin to your path"

