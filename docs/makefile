all: index.html SORD.html

%.html: %.md style.html Makefile
	pandoc \
	--smart \
	--standalone \
	--write=html5 \
	--css=style.css \
	--include-in-header=style.html \
	$< -o $@

