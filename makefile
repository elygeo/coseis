all : Coseis.html SORD.html

Coseis.html : README.txt docs/style.html makefile
	pandoc -sSH docs/style.html -w html5 $< -o $@

%.html : docs/%.txt docs/style.html makefile
	pandoc -sSH docs/style.html -w html5 $< -o $@
