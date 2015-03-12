all: Coseis.html SORD.html

%.html: %.rst style.css
	rst2html.py \
	--strict \
	--no-toc-backlinks \
	--cloak-email-addresses \
	--initial-header-level=3 \
	--stylesheet-path=style.css \
	$< | sed 's|<col.*>||; s|</colgroup>||' > $@

