run/example.png : run
	python plot.py

run : sim.py
	mkdir run
	sord sim.yaml --run=exec

clean:
	rm -rf test/*
