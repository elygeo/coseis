#!/bin/bash

cd ..

gtar -hzvc -f fsord/fsord.tgz fsord/src fsord/makefile fsord/script fsord/tarball.sh

cd fsord

tag=$( date +%Y-%m-%d-%H-%M-%S )

cp fsord.tgz "save/fsord-$tag.tgz"

