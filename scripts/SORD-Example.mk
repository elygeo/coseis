DIR = repo/SORD-Example

$(DIR)/SORD-Example.png: $(DIR) sord-example-plot.py
	python sord-example-plot.py

$(DIR): sord-example-sim.yaml
	mkdir $(DIR)
	cd $(DIR) && sord.py FIXME/sord-example-sim.yaml

