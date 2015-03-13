DIR = repo/Explosion

$(DIR)/Explosion.png: $(DIR) explosion-plot.py
	python explosion-plot.py

$(DIR): explosion-sim.py
	python explosion-sim.py

