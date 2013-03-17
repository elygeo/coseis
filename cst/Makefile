# Coseis Makefile
# TODO: nested make for test, sord, and cvms

# TODO: turn this into a rule
trinterp_ext.c : trinterp_ext.pyx
	cython trinterp_ext.pyx

# FIXME: this doesn't work
%.c : $.pyx
	cython $<

clean :
	rm -rf build *.so *.pyc

distclean : clean
	rm -rf data trinterp_ext.c

