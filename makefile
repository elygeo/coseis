all : index.html sord.html

index.html : README.md docs/style.html makefile
	pandoc -Ssw html5 -H docs/style.html $< -o $@

sord.html : docs/SORD.txt docs/style.html makefile
	pandoc -Ssw html5 -H docs/style.html \
	-M link-citations \
	--csl=docs/chicago-mod.csl \
	--filter=pandoc-citeproc \
	--bibliography=docs/bibliography.json \
	$< -o $@

