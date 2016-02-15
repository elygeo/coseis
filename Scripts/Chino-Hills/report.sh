#!/bin/bash -e

cp report.rst run/plot/
cd run/plot

for f in ci-*.pdf; do
cat << EOF >> report.rst
.. figure:: $f

    Material profiles (left), time history (center), and Fourier spectra (right)
    for recorded (black) and simulated 0.1 to 1.0 Hz ground velocity (cm/s) for
    CVM-S (red), CVM-H (blue), and CVM-H + GLT (green).
EOF
done

cat << EOF > style.tex
\usepackage[margin=0.5in]{geometry}
\usepackage[margin=0.5in]{caption}
\pagestyle{empty}
EOF

f="report"

rst2latex.py \
    --documentoptions='12pt' \
    --stylesheet='style.tex' \
    --embed-stylesheet \
    --latex-preamble= \
    --no-doc-title \
    "$f.rst" > "$f.tex"

pdflatex "$f"
pdflatex "$f"

rm "$f.rst" "$f.tex" "$f.out" "$f.aux" "$f.log" style.tex

