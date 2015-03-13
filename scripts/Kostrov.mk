DIR = repo/Kostrov

$(DIR)/Kostrov.pdf: $(DIR) kostrov-plot.py
	python kostrov-plot.py

$(DIR): kostrov-sim.yaml
	mkdir $(DIR)
	cd $(DIR) && sord.py FIXME/kostrov-sim.yaml

