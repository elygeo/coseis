#!/bin/bash -e
pwd="${PWD}"
cd "${1:-.}"
prefix="${PWD}"
echo -en "Install Enthought Python Distribution in ${prefix}? [y/N]: "
read confirm
[ "$confirm" = "y" ]

# Enthought Python Distribution
# License required (free for academic use).
# See http://enthought.com/products/getepd.php
if [ "${OSTYPE}" = 'darwin10.0' ]; then

# Mac OS X
url="http://download.enthought.com/epd-7.1/epd-7.1-2-macosx-i386.dmg"
url="http://download.enthought.com/epd-7.1/epd-7.1-2-macosx-x86_64.dmg"
url="http://download.enthought.com/epd_free/epd_free-7.1-1-macosx-i386.dmg"
tag=$( basename "$url" )
cd "${prefix}"
[ -e "${tag}.dmg" ] || curl -O "${url}"
hdid "${tag}"
sudo installer -pkg '/Volumes/EPD-7.1/EPD.mpkg' -target '/'
export PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"

else

# Linux
url="http://download.enthought.com/epd-7.1/epd-7.1-2-rh5-x86_64.sh"
url="http://download.enthought.com/epd-7.1/epd-7.1-2-rh3-x86_64.sh"
url="http://download.enthought.com/epd_free/epd_free-7.1-2-rh5-x86_64.sh"
tag=$( basename "$url" .sh )
cd "${prefix}"
[ -e "${tag}.sh" ] || curl -O "${url}"
bash "${tag}.sh"
ln -s "${tag}" python
export PATH="${prefix}/${tag}/bin:${PATH}"

fi

# Packages
easy_install pip
pip install virtualenv
pip install pypdf
pip install web.py
pip install GitPython
pip install obspy.core
pip install obspy.mseed
pip install obspy.sac
pip install obspy.gse2
pip install obspy.imaging
pip install obspy.signal

cd "${pwd}"

