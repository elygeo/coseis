all : index.html sord.html

index.html : README.md docs/header.html makefile
	pandoc -Ssw html5 -H docs/header.html $< -o $@

sord.html : docs/SORD.txt docs/header.html makefile
	pandoc -Ssw html5 -H docs/header.html $< -o $@

