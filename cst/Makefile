wrapper.c : wrapper.pyx

%.c : %.pyx
	cython -a -X boundscheck=False,wraparound=False,cdivision=True $<

