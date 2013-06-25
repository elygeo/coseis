# Wat2Q IBM Blue Gene/Q

MODE = mpi
CC = /bgsys/drivers/ppcfloor/comm/xl/bin/mpixlcc_r
FC = /bgsys/drivers/ppcfloor/comm/xl/bin/mpixlf2003_r
LD = /bgsys/drivers/ppcfloor/comm/xl/bin/mpixlf2003_r

CFLAGS = $(LDFLAGS) -qlist -qreport
FFLAGS = $(LDFLAGS) -qlist -qreport
LDFLAGS = -g -O3 -qsuppress=cmpmsg
LIBS = -lSPI_upci_cnk /bgsys/drivers/ppcfloor/bgpm/lib/libbgpm.a

ifdef REAL8
    FFLAGS += -qrealsize=8
endif

ifdef OMP
    LDFLAGS += -qsmp=omp:noauto
endif
