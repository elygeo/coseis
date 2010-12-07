#!/bin/bash -e

f="chino-cvm-0200-flat"
f="chino-cvm-0050-flat"
d="run/sim/$f"
cp report.rst "$d/$f.rst"
cd "$d"

cat << EOF > style.tex
\usepackage[margin=0.5in]{caption}
\usepackage[top=1in,bottom=1in,left=1.25in,right=1.25in]{geometry}
\pagestyle{empty}
EOF

rst2latex.py \
    --no-doc-title \
    --documentoptions='12pt' \
    --latex-preamble= \
    --stylesheet='style.tex' \
    --embed-stylesheet \
    "$f.rst" > "$f.tex"
pdflatex "$f"
pdflatex "$f"
rm "$f.rst" "$f.tex" "$f.out" "$f.aux" "$f.log" style.tex

