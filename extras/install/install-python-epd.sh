#!/bin/bash -e
# Install Enthought Python Distribution

# http://download.enthought.com/epd/installs/epd-6.1-1-macosx-i386.dmg
url="http://download.enthought.com/epd/installs/epd-6.1-1-rh3-x86.sh"
url="http://download.enthought.com/epd/installs/epd-6.1-1-rh5-x86.sh"

# Set loction here:
path="\${HOME}/local"

# confirm
prefix="$( eval echo ${path} )"
echo -n "Installing Python in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]
mkdir -p "${prefix}"

# install
version=$( basename "$url" .sh )
cd "${prefix}"
curl -O "${url}"
bash "${version}.sh"
ln -s "${version}" python
export PATH="${prefix}/python/bin:${PATH}"

echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${path}/python/bin:\${PATH}\""

