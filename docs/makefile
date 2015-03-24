all: Coseis.html SORD.html

%.html: %.md style.css makefile
	pandoc \
	--smart \
	--standalone \
	--write=html5 \
	--css=style.css \
	--include-after-body=body-after.html \
	--include-before-body=body-before.html \
	$< -o $@

