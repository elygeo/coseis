.PHONY: sim
sim: run/sim
run/sim: sord.py run/mesh
	python sord.py

run/mesh: cvm.py run/data
	python cvm.py

.PHONY: map
map: run/plot/map.pdf
run/plot/map.pdf: map.py run/map-data
	python map.py

run/map-data: map-data.py run/data
	python map-data.py

run/data: data.py
	python data.py

clean:
	/bin/rm -rf run
