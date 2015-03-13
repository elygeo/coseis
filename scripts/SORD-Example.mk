TAG = SORD-Example
DIR = run/$(TAG)

$(DIR)/$(TAG).png : $(DIR) $(TAG)-plot.py
	python $(TAG)-plot.py

$(DIR) : $(TAG)-sim.yaml
	mkdir $(DIR)
	cd $(DIR) && sord.py $(CURDIR)/$(TAG)-sim.yaml

