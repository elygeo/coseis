#!/bin/bash -e

# set location here:
path="\${HOME}/local"
prefix="$( eval echo ${path} )"

# confirm
echo -n "Installing in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]
mkdir -p "${prefix}"

# Enthought Python Distribution
# http://download.enthought.com/epd/installs/epd-6.1-1-macosx-i386.dmg
url="http://download.enthought.com/epd/installs/epd-6.1-1-rh3-x86.sh"
url="http://download.enthought.com/epd/installs/epd-6.1-1-rh5-x86.sh"
version=$( basename "$url" .sh )
cd "${prefix}"
curl -O "${url}"
bash "${version}.sh"
ln -s "${version}" python

# path
export PATH="${prefix}/python/bin:${PATH}"
echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${path}/python/bin:\${PATH}\""

