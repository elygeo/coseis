#!/bin/bash -e
# This script installs Enthought Python under Linux/UNIX.

# Set loctions here:
prefix="${HOME}/local"

# Set version here:
# version=epd_py25-4.2.30201-win32-x86.msi
# version=epd_py25-4.2.30201-macosx-u.dmg
version=epd_py25-4.2.30101-SunOS_5.10-x86.sh
version=epd_py25-4.2.30201-rh3-x86.installer
version=epd_py25-4.2.30201-rh5-x86.installer
version=epd_py25-4.2.30201-rh3-amd64.installer
version=epd_py25-4.2.30201-rh5-amd64.installer

echo -n "Installing Enthought Python ${version} in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

export PATH="${prefix}/bin:${PATH}"
mkdir -p "${prefix}"
cd "${prefix}"

wget "http://download.enthought.com/epd/installs/$version"
bash "$version"

echo "Don't forget to add \${prefix}/bin to your path"

