TAG = LOH1
DIR = run/$(TAG)

$(DIR)/$(TAG).pdf : $(DIR) $(TAG)-plot.py
	python $(TAG)-plot.py

$(DIR) : $(TAG)-sim.py
	python $(TAG)-sim.py

