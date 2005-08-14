#!/bin/bash

cd ..

gtar -hzvc -f fsord/fsord.tgz fsord/*.f95 fsord/tarball.sh

cd fsord

tag=$( date +%Y-%m-%d-%H-%M-%S )

cp fsord.tgz "save/fsord-$tag.tgz"

