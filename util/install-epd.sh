#!/bin/bash -e
prefix="${1:-${HOME}/local}"
pwd="${PWD}"

# Enthought Python Distribution
# License required (free for academic use).
# See http://enthought.com/products/getepd.php
if [ "${OSTYPE}" = 'darwin10.0' ]; then

# Mac OS X
url="http://download.enthought.com/epd/installs/epd-6.3-1-macosx-i386.dmg"
tag=$( basename "$url" )
cd "${prefix}"
#curl -O "${url}"
hdid "${tag}"
sudo installer -pkg '/Volumes/EPD-6.3/EPD.mpkg' -target '/'
export PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"

else

# Linux
url="http://download.enthought.com/epd/installs/epd-6.3-1-rh3-x86.sh"
url="http://download.enthought.com/epd/installs/epd-6.3-1-rh5-x86.sh"
url="http://www.enthought.com/repo/.hide_epd_installers/epd-6.3-1-rh3-x86_64.sh"
url="http://www.enthought.com/repo/.hide_epd_installers/epd-6.3-1-rh5-x86_64.sh"
url="http://download.enthought.com/epd63/epd-6.3-1-rh3-x86_64.sh"
url="http://download.enthought.com/epd63/epd-6.3-1-rh5-x86_64.sh"
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
pip install pypdf
pip install GitPython
pip install web.py

cd "${pwd}"

