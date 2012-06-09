#!/bin/bash

cd ../..
pyflakes setup.py
pyflakes bin/*
pyflakes doc/*.py
pyflakes cst/*.py
pyflakes cst/*/*.py
pyflakes scripts/*/*.py | grep -v 'ws-meta-in.py'

