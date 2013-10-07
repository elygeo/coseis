plot : run/Kostrov.pdf

run/Kostrov.pdf : run plot.py
	python plot.py

run : sim.yaml
	mkdir run
	sord sim.yaml

clean :
	rm -rf run
