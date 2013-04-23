# Coseis Makefile

interpolate_ext.c : interpolate_ext.pyx

clean :
	rm -rf build *.so *.pyc

distclean : clean
	rm -rf data trinterp_ext.c

%.c : %.pyx
	cython $<

