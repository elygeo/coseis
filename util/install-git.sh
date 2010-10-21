#!/bin/bash -e
prefix="${1:-${HOME}/local}"
pwd="${PWD}"

# Git
url='http://kernel.org/pub/software/scm/git/git-1.7.3.1.tar.gz'
tag=$( basename "$url" .tar.gz )
cd "${prefix}"
curl -L "${url}" | tar zx
cd "${tag}"
make prefix="${prefix}"
make prefix="${prefix}" install
export PATH="${prefix}/bin:${PATH}"
cd "${pwd}"

