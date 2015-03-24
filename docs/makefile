all: ../index.html SORD.html

../index.html: ../README.md style.css makefile
	pandoc \
	--smart \
	--standalone \
	--write=html5 \
	--css=docs/style.css \
	--include-after-body=body-after.html \
	--include-before-body=body-before.html \
	$< -o $@

%.html: %.md style.css makefile
	pandoc \
	--smart \
	--standalone \
	--write=html5 \
	--css=style.css \
	--include-after-body=body-after.html \
	--include-before-body=body-before.html \
	$< -o $@

