#!/bin/bash -e
# This script installs Enthought Python under Linux/UNIX.

# Set version here:
# rh3 seems to work for most linux distros. Fedora 6 = RHEL 5
# http://download.enthought.com/epd/installs/epd-5.1.1-win32-x86.msi
# http://download.enthought.com/epd/installs/epd-5.1.1-macosx-i386.dmg
link="http://download.enthought.com/epd/installs/epd-5.1.1-SunOS_5.10-x86.sh"
link="http://download.enthought.com/epd/installs/epd-5.1.1-rh5-x86.sh"
link="http://download.enthought.com/epd/installs/epd-5.1.1-rh3-x86.sh"

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
ln -sf "${version}" python
easy_install bzr

echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${prefix}/python/bin:\${PATH}\""

