#!/bin/bash -e

f = "chino-cvm-0200-flat"
f = "chino-cvm-0050-flat"
d = "run/sim/$f"

cp report.rst "$d/$f.rst"
cd "$d"

stylesheet = """
\usepackage[margin=1in]{geometry}
\usepackage[margin=0.5in]{caption}
\pagestyle{empty}
"""

rst2latex.py
    --documentoptions='12pt'
    --stylesheet='style.tex'
    --embed-stylesheet
    --latex-preamble=
    --no-doc-title
    "$f.rst" > "$f.tex"

pdflatex "$f"
pdflatex "$f"

rm "$f.rst" "$f.tex" "$f.out" "$f.aux" "$f.log" style.tex

