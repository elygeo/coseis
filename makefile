all : index.html SORD.html

%.html : docs/%.txt docs/style.html makefile
	pandoc -sSH docs/style.html -w html5 $< -o $@
