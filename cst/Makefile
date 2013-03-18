# Coseis Makefile

trinterp_ext.c : trinterp_ext.pyx

clean :
	rm -rf build *.so *.pyc

distclean : clean
	rm -rf data trinterp_ext.c

%.c : %.pyx
	cython $<

