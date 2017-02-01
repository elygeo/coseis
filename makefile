all : index.html sord.html

index.html : README.md docs/style.html makefile
	pandoc -Sw html5 -H docs/style.html --template docs/template.html \
	--email-obfuscation references \
	$< > $@

sord.html : docs/SORD.txt docs/style.html makefile
	pandoc -Sw html5 -H docs/style.html --template docs/template.html \
	--email-obfuscation references \
	--bibliography docs/bibliography.json \
	--metadata link-citations \
	--filter pandoc-citeproc \
	--filter pandoc-scholar.py \
	$< > $@
