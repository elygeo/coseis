# Wat2Q IBM Blue Gene/Q

MODE = mpi
FC = /bgsys/drivers/ppcfloor/comm/xl/bin/mpixlf2003_r
FFLAGS = $(LDFLAGS) -qlist -qreport
LDFLAGS = -g -O3 -qsuppress=cmpmsg
