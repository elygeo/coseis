TAG = Kosrov
DIR = run/$(TAG)

$(DIR)/$(TAG).pdf : $(DIR) $(TAG)-plot.py
	python $(TAG)-plot.py

$(DIR) : $(TAG)-sim.yaml
	mkdir $(DIR)
	cd $(DIR) && sord.py $(CURDIR)/$(TAG)-sim.yaml

