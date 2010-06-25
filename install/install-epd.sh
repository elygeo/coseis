#!/bin/bash -e

# Enthought Python Distribution
if "${OSTYPE}" = 'darwin10.0'; then

rul="http://download.enthought.com/epd/installs/epd-6.2-2-macosx-i386.dmg"
ver=$( basename "$url" )
open "${ver}"

else

prefix="${1:-${HOME}/local}"
url="http://download.enthought.com/epd/installs/epd-6.2-2-rh5-x86.sh"
ver=$( basename "$url" .sh )
cd "${prefix}"
curl -O "${url}"
bash "${ver}.sh"
ln -s "${ver}" python
export PATH="${prefix}/python/bin:${PATH}"

fi

# Packages
easy_install pip
pip install virtualenv
pip install bzr
pip install pypdf
. install-obspy.sh "${prefix}"

