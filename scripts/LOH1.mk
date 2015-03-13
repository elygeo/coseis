DIR = repo/LOH1

$(DIR)/LOH1.pdf: $(DIR) loh1-plot.py
	python loh1-plot.py

$(DIR): loh1-sim.py
	python loh1-sim.py

