#!/bin/bash -e
# Install Enthought Python Distribution under Linux/UNIX.

# Set version here:
# http://download.enthought.com/epd/installs/epd-6.0.0-win-x86.msi
# http://download.enthought.com/epd/installs/epd-6.0.0-macosx-i386.dmg
link="http://download.enthought.com/epd/installs/epd-5.1.1-SunOS_5.10-x86.sh"
link="http://download.enthought.com/epd/installs/epd-5.1.1-rh3-x86.sh"
link="http://download.enthought.com/epd/installs/epd-6.0.0-rh5-x86.sh"
version=$( basename "$link" .sh )

# Set loction here:
path="/usr/local"
path="\${HOME}/local"

uname -a
getconf LONG_BIT

prefix="$( eval echo ${path} )"
echo -n "Installing Enthought Python ${version} in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

mkdir -p "${prefix}"
cd "${prefix}"

curl -O "${link}"
bash "${version}.sh"
[ -e python ] || ln -s "${version}" python

echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${path}/python/bin:\${PATH}\""

