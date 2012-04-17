#!/bin/bash -e
prefix="${HOME}/local"
echo -en "Install Git in ${prefix}? [y/N]: "
read confirm
[ "$confirm" = "y" ]

# Git
cd "${prefix}"
url='http://kernel.org/pub/software/scm/git/git-1.7.10.tar.gz'
tag=$( basename "$url" .tar.gz )
curl -L "${url}" | tar zx
cd "${tag}"
make prefix="${prefix}" install

