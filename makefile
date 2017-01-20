all : index.html sord.html

sord.html : docs/%.txt docs/style.html makefile
	pandoc -sSH docs/style.html -w html5 $< -o $@

%.html : docs/%.txt docs/style.html makefile
	pandoc -sSH docs/style.html -w html5 $< -o $@
