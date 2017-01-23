all : index.html sord.html

index.html : README.md docs/style.html makefile
	pandoc -sSH docs/style.html -w html5 $< -o $@

sord.html : docs/SORD.txt docs/style.html makefile
	pandoc -sSH docs/style.html -w html5 $< -o $@

