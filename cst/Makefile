interp_.c : interp_.pyx

%.c : %.pyx
	cython -a -X boundscheck=False,wraparound=False,cdivision=True $<

