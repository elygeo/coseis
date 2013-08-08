all: ../www/index.html ../www/sord.html

../www/%.html : %.rst style.css
	rst2html.py \
	--strict \
	--no-toc-backlinks \
	--cloak-email-addresses \
	--stylesheet-path=style.css \
	$< | sed 's|<col.*>||; s|</colgroup>||' > $@
