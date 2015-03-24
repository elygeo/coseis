# Coseis Makefile

interp_.c : interp_.pyx

clean :
	rm -rf build *.so *.pyc

distclean : clean
	rm -rf repo interp_.c

%.c : %.pyx
	cython $<

