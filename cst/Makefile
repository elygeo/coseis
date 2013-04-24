# Coseis Makefile

interp_.c : interp_.pyx

clean :
	rm -rf build *.so *.pyc

distclean : clean
	rm -rf data trinterp_ext.c

%.c : %.pyx
	cython $<

