all: $(patsubst %.yaml,%.json,$(wildcard *.yaml))

clean:
	rm -f *.json

%.json: %.yaml
	./yaml2json $<

