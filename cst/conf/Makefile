all: $(patsubst %.yaml,%.json,$(wildcard *.yaml))

%.json: %.yaml
	yaml2json $< > $@

