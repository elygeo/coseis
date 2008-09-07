#!/bin/bash -e
# Make SORD code

# Command line arguments
p=yes
s=yes
optimize=O
while getopts spOg opt; do
case "$opt" in
    s) unset p ;;    # serial mode
    p) unset s ;;    # parallel mode
    O) optimize=O ;; # optimize
    g) optimize=g ;; # debug
    *) exit 1 ;;
esac
done

# Make tmp dir for storing compiled binaries
cd "$( dirname $0 )"
mkdir -p tmp

# Configure
. sh/config
case $optimize in
    O) fflags=$oflags; ;;
    g) fflags=$gflags; ;;
esac

# Source files
base="
    globals.f90
    diffcn.f90
    diffnc.f90
    hourglass.f90
    bc.f90
    surfnormals.f90
    util.f90
    frio.f90"
common="
    inread.f90
    setup.f90
    arrays.f90
    gridgen.f90
    debug.f90
    iosequence.f90
    source.f90
    material.f90
    fault.f90
    metadata.f90
    resample.f90
    checkpoint.f90
    timestep.f90
    stress.f90
    acceleration.f90
    sord.f90"

# Compile
cd src
[ "$s" ] && ../sh/compile "$sfc $fflags -o" ../tmp/sord-s $base serial.f90 $common
[ "$p" ] && ../sh/compile "$pfc $fflags -o" ../tmp/sord-p $base mpi.f90 $common

# Save source code
sh/tarball

