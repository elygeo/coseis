plot : run/example.png

run/example.png : run plot.py
	python plot.py

run : sord.yaml
	mkdir run
	sord sord.yaml

clean :
	rm -rf run

