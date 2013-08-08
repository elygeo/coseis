#!/bin/bash

cd ../..
pyflakes setup.py
pyflakes bin/*
pyflakes doc/*.py
pyflakes cst/*.py
pyflakes cst/tests/*.py
pyflakes cst/sord/*.py
pyflakes cst/cvms/*.py
pyflakes scripts/*/*.py \
    | grep -v 'ws-meta-in.py'

