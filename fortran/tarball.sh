#!/bin/bash -e

cd ..

gtar -hzc -f fsord/fsord.tgz fsord/*.f95 fsord/setup.sh fsord/tarball.sh

cd fsord

tag=$( date +%Y-%m-%d-%H-%M-%S )

cp fsord.tgz "save/fsord-$tag.tgz"

