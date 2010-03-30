#!/bin/bash -e

# set location here:
path="\${HOME}/local"
prefix="$( eval echo ${path} )"

# confirm
echo -n "Installing in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]
mkdir -p "${prefix}"

# Python
version="2.6.5"
cd "${prefix}"
curl "http://www.python.org/ftp/python/${version}/Python-${version}.tgz" | tar zx
cd "Python-${version}"
./configure --prefix="${prefix}"
make
make install

# setuptools
curl -O http://peak.telecommunity.com/dist/ez_setup.py
python ez_setup.py --prefix="${prefix}"
#curl -O http://python-distribute.org/distribute_setup.py
#python distribute_setup.py --prefix="${prefix}"

# PATH
echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${path}/bin:\${PATH}\""
export PATH="${prefix}/bin:${PATH}"

