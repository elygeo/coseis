#!/bin/bash -e
# This script installs Enthought Python under Linux/UNIX.

# Set loctions here:
prefix="${HOME}/local"

# Set version here:
# rh3 seems to work for most linux distros. Fedora 6 = RHEL 5
# version=epd_py25-4.2.30201-win32-x86.msi
# version=epd_py25-4.2.30201-macosx-u.dmg
version=epd_py25-4.2.30101-SunOS_5.10-x86.sh
version=epd_py25-4.2.30201-rh5-x86.installer
version=epd_py25-4.2.30201-rh3-x86.installer
version=epd_py25-4.2.30201-rh5-amd64.installer
version=epd_py25-4.2.30201-rh3-amd64.installer
# version=epd_py25-4.3.0-win32-x86.msi
# version=epd_py25-4.3.0-macosx.dmg
version=epd_py25-4.3.0-SunOS_5.10-x86.sh
version=epd_py25-4.3.0-rh5-x86.sh
version=epd_py25-4.3.0-rh3-x86.sh
version=epd_py25-4.3.0-rh5-amd64.sh
version=epd_py25-4.3.0-rh3-amd64.sh

uname -a
getconf LONG_BIT

echo -n "Installing Enthought Python ${version} in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

mkdir -p "${prefix}"
cd "${prefix}"

wget "http://download.enthought.com/epd/installs/$version"
bash "$version"

echo 'Now add this to your .bashrc or .profile:'
echo 'export PATH="${HOME}/local/epd/bin:${PATH}"'

