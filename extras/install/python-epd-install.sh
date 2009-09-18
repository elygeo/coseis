#!/bin/bash -e
# This script installs Enthought Python under Linux/UNIX.

# Set loctions here:
prefix="/usr/local"
prefix="${HOME}/local"

# Set version here:
# rh3 seems to work for most linux distros. Fedora 6 = RHEL 5
# version=epd_py25-4.3.0-win32-x86.msi
# version=epd_py25-4.3.0-macosx.dmg
version=epd_py25-4.3.0-SunOS_5.10-x86.sh
version=epd_py25-4.3.0-rh5-x86.sh
version=epd_py25-4.3.0-rh3-x86.sh
version=epd_py25-4.3.0-rh5-amd64.sh
version=epd_py25-4.3.0-rh3-amd64.sh
link="http://download.enthought.com/epd/installs/$version"
# http://download.enthought.com/epd/installs/epd-5.0.0-win32-x86.msi
# http://download.enthought.com/epd/installs/epd-5.0.0-macosx-i386.dmg
link=http://download.enthought.com/epd/installs/epd-5.0.0-SunOS_5.10-x86.sh
link=http://download.enthought.com/epd/installs/epd-5.0.0-rh3-x86.sh
link=http://download.enthought.com/epd/installs/epd-5.0.0-rh5-x86.sh
link=http://download.enthought.com/epd/installs/epd-5.0.0-rh3-x86_64.sh
link=http://download.enthought.com/epd/installs/epd-5.0.0-rh5-x86_64.sh
version="${link##*/}"

uname -a
getconf LONG_BIT

echo -n "Installing Enthought Python ${version} in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

mkdir -p "${prefix}"
cd "${prefix}"

wget "$link"
bash "$version"

echo 'Now add this to your .bashrc or .profile:'
echo 'export PATH="${HOME}/local/epd/bin:${PATH}"'

