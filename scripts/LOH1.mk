plot: run/LOH.1.pdf

run/LOH.1.pdf: run plot.py
	python plot.py

run: sord.py
	python sord.py

clean:
	rm -rf run
