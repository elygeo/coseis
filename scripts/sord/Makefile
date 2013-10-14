plot : run/Example.png

run/Example.png : run plot.py
	python plot.py

run : parameters.yaml
	mkdir run
	sord parameters.yaml

clean :
	rm -rf run

