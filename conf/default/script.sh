#!/bin/bash -e

cd "%(rundir)s"

echo "$( date ): %(name)s started" >> log
%(pre)s
%(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

