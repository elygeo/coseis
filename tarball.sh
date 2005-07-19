#!/bin/bash

cd ..

gtar -hzvc -f sord/sord.tgz sord/*.m sord/readme sord/tarball.sh sord/fortran sord/makefile

cd sord

tag=$( date +%Y-%m-%d-%H-%M-%S )

cp sord.tgz "save/sord-$tag.tgz"

