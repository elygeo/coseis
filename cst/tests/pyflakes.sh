#!/bin/bash

cd ../..
pyflakes setup.py
pyflakes Docs/*.py
pyflakes cst/*.py
pyflakes cst/tests/*.py
pyflakes cst/sord/*.py
pyflakes cst/cvms/*.py
pyflakes Scripts/*/*.py
