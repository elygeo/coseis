#!/bin/bash -e

rst2html.py -g -d -s --strict --cloak-email-addresses --link-stylesheet  user-guide.txt > user-guide.html

stop

rst2latex.py -g -d -s --strict user-guide.txt > user-guide.tex
pdflatex user-guide.tex
rm user-guide.log user-guide.out user-guide.aux user-guide.tex
