#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# Enthought Python Distribution
# http://download.enthought.com/epd/installs/epd-6.1-1-macosx-i386.dmg
url="http://download.enthought.com/epd/installs/epd-6.1-1-rh3-x86.sh"
url="http://download.enthought.com/epd/installs/epd-6.1-1-rh5-x86.sh"
ver=$( basename "$url" .sh )
cd "${prefix}"
curl -O "${url}"
bash "${ver}.sh"
ln -s "${ver}" python
export PATH="${prefix}/python/bin:${PATH}"

