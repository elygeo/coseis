TAG = Explosion
DIR = run/$(TAG)

$(DIR)/$(TAG).png : $(DIR) $(TAG)-plot.py
	python $(TAG)-plot.py

$(DIR) : $(TAG)-sim.py
	python $(TAG)-sim.py

