#!/bin/bash -e
# This script installs Enthought Python under Linux/UNIX.

# Set version here:
# rh3 seems to work for most linux distros. Fedora 6 = RHEL 5
# http://download.enthought.com/epd/installs/epd-5.1.0-win32-x86.msi
# http://download.enthought.com/epd/installs/epd-5.1.0-macosx-i386.dmg
link="http://download.enthought.com/epd/installs/epd-5.1.0-SunOS_5.10-x86.sh"
link="http://download.enthought.com/epd/installs/epd-5.1.0-rh5-x86_64.sh"
link="http://download.enthought.com/epd/installs/epd-5.1.0-rh5-x86.sh"
link="http://download.enthought.com/epd/installs/epd-5.1.0-rh3-x86_64.sh"
link="http://download.enthought.com/epd/installs/epd-5.1.0-rh3-x86.sh"

version=$( basename "$link" .sh )

# Set loction here:
prefix="/usr/local"
prefix="${HOME}/local"

uname -a
getconf LONG_BIT

echo -n "Installing Enthought Python ${version} in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

mkdir -p "${prefix}"
cd "${prefix}"

curl -O "${link}"
bash "${version}.sh"
ln -s "${version}" python

echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${prefix}/python/bin:\${PATH}\""

