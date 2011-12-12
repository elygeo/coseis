#!/bin/bash -e
pwd="${PWD}"
cd "${1:-.}"
prefix="${PWD}"
echo -en "Install Git in ${prefix}? [y/N]: "
read confirm
[ "$confirm" = "y" ]

# Git
url='http://kernel.org/pub/software/scm/git/git-1.7.8.tar.gz'
tag=$( basename "$url" .tar.gz )
cd "${prefix}"
curl -L "${url}" | tar zx
cd "${tag}"
make prefix="${prefix}"
make prefix="${prefix}" install
export PATH="${prefix}/bin:${PATH}"
cd "${pwd}"

