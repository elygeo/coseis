#!/bin/bash -e
# This script installs official Python.
# For more bells and whistles, the Enthought Python Distribution highly recommended:
# wget http://download.enthought.com/epd/installs/epd_py25-4.2.30201-macosx-u.dmg
# wget http://download.enthought.com/epd/installs/epd_py25-4.2.30201-rh3-amd64.installer
# wget http://download.enthought.com/epd/installs/epd_py25-4.2.30201-rh3-x86.installer
# wget http://download.enthought.com/epd/installs/epd_py25-4.2.30201-rh5-amd64.installer
# wget http://download.enthought.com/epd/installs/epd_py25-4.2.30201-rh5-x86.installer
# wget http://download.enthought.com/epd/installs/epd_py25-4.2.30201-win32-x86.msi
# wget http://download.enthought.com/epd/installs/epd_py25-4.2.30101-SunOS_5.10-x86.sh

version="2.6.2"
prefix="${HOME}/local"

echo -n "Installing Python-${version} and setuptools in ${prefix}/local. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

export PATH="${prefix}/bin:${PATH}"
mkdir -p "${prefix}"
cd "${prefix}"

wget "http://www.python.org/ftp/python/${version}/Python-${version}.tgz"
tar zxvf "Python-${version}.tgz"
cd "Python-${version}"
./configure --prefix="${prefix}"
make
make install

wget http://peak.telecommunity.com/dist/ez_setup.py
python ez_setup.py --prefix="${prefix}"

echo "Don't forget to add \${prefix}/bin to your path"

