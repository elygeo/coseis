#!/bin/bash -e

echo -n "Installing Python and setuptools in ${HOME}/local. Are you sure? [y/N]: "
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

wget http://peak.telecommunity.com/dist/ez_setup.py
python ez_setup.py --prefix=$HOME/local

echo "Don't forget to add \${HOME}/local/bin to your path"

