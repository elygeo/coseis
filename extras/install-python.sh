#!/bin/bash -e

echo -n "Installing Python, Numpy and Bazaar in ${HOME}/local. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

export PATH=${HOME}/local/bin:${PATH}
mkdir -p ${HOME}/local
cd ${HOME}/local

wget http://www.python.org/ftp/python/2.6/Python-2.6.tgz
tar zxvf Python-2.6.tgz
cd Python-2.6
./configure --prefix=$HOME/local
make
make install

wget http://pypi.python.org/packages/2.6/s/setuptools/setuptools-0.6c9-py2.6.egg
bash setuptools-0.6c9-py2.6.egg
easy_install numpy
easy_install bzr

echo "Don't forget to add \${HOME}/local/bin to your path"

