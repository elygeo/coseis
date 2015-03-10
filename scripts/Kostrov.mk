plot: run/kostrov/Kostrov.pdf

run/kostrov/Kostrov.pdf: run plot.py
	python plot.py

run/kostrov: sord.yaml
	mkdir run/kostrov
	cd run/kostrov && sord ../../sord.yaml

