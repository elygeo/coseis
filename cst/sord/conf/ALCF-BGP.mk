# ALCF IBM Blue Gene/P

MODE = mpi

ifdef TAU
    CC = tau_cc.sh
    FC = tau_f90.sh
else
    CC = mpixlc_r
    FC = mpixlf2003_r
    LIBS = /home/morozov/lib/libmpihpm.a
endif

CFLAGS = $(LDFLAGS) -qlist -qreport
FFLAGS = $(LDFLAGS) -qlist -qreport
LDFLAGS = -g -O3 -qsuppress=cmpmsg

ifdef REAL8
    FFLAGS += -qrealsize=8
endif

ifdef OMP
    LDFLAGS += -qsmp=omp
endif
