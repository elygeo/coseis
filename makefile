all : index.html sord.html

index.html : README.md docs/header.html makefile
	pandoc -Ssw html5 -H docs/header.html $< -o $@

sord.html : docs/SORD.txt docs/header.html makefile
	pandoc -Ssw html5 -H docs/header.html \
	-M link-citations \
	--csl=docs/chicago-mod.csl \
	--filter=pandoc-citeproc \
	--filter=pandoc-scholar.py \
	--bibliography=docs/bibliography.json \
	$< -o $@

