all: ../WWW/index.html ../WWW/sord.html

../WWW/%.html: %.rst style.css
	rst2html.py \
	--strict \
	--no-toc-backlinks \
	--cloak-email-addresses \
	--initial-header-level=3 \
	--stylesheet-path=style.css \
	$< | sed 's|<col.*>||; s|</colgroup>||' > $@
