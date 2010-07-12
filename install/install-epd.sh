#!/bin/bash -e
prefix="${1:-${HOME}/local}"
pwd="${PWD}"

# Enthought Python Distribution
if [ "${OSTYPE}" = 'darwin10.0' ]; then

# Mac OS X
url="http://download.enthought.com/epd/installs/epd-6.2-2-macosx-i386.dmg"
tag=$( basename "$url" )
cd "${prefix}"
#curl -O "${url}"
hdid "${tag}"
sudo installer -pkg '/Volumes/EPD-6.2/EPD.mpkg' -target '/'
export PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"

else

# Linux
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

cd "${pwd}"

