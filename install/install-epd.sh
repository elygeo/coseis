#!/bin/bash -e

# Enthought Python Distribution
if "${OSTYPE}" = 'darwin10.0'; then

rul="http://download.enthought.com/epd/installs/epd-6.2-2-macosx-i386.dmg"
tag=$( basename "$url" )
hdid "${tag}"
installer -pkg '/Volumes/EPD-6.2/EPD.mpkg' -target '/'

else

prefix="${1:-${HOME}/local}"
url="http://download.enthought.com/epd/installs/epd-6.2-2-rh5-x86.sh"
tag=$( basename "$url" .sh )
cd "${prefix}"
curl -O "${url}"
bash "${tag}.sh"
ln -s "${tag}" python
export PATH="${prefix}/python/bin:${PATH}"

fi

# Packages
easy_install pip
pip install virtualenv
pip install bzr
pip install pypdf
. install-obspy.sh "${prefix}"

