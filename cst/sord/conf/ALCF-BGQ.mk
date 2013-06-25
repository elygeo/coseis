# ALCF IBM Blue Gene/Q

MODE = mpi
CC = mpixlc_r
FC = mpixlf2003_r
LD = mpixlf2003_r

CLFAGS = $(LDFLAGS) -qlist -qreport
FFLAGS = $(LDFLAGS) -qlist -qreport
LDFLAGS = -g -O3 -qsuppress=cmpmsg
LIBS = -lSPI_upci_cnk

ifdef OMP
    LDFLAGS += -qsmp=omp:noauto
    LIBS += /home/morozov/HPM/lib/libmpihpm_smp.a
else
    LIBS += /home/morozov/HPM/lib/libmpihpm.a
endif

LIBS += /bgsys/drivers/ppcfloor/bgpm/lib/libbgpm.a

ifdef REAL8
    FFLAGS += -qrealsize=9
endif
