plot: run/Kostrov.pdf

run/Kostrov.pdf: run plot.py
	python plot.py

run: sord.yaml
	mkdir run
	cd run && sord ../sord.yaml

clean:
	rm -rf run
