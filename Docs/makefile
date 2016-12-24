all : index.html SORD.html

%.html : %.txt style.html makefile
	pandoc \
	--smart \
	--standalone \
	--write=html5 \
	--include-in-header=style.html \
	$< -o $@
