# KAUST Shaheen: IBM Blue Gene/P

MODE = mpi
CC = *FIXME*
FC = *FIXME*
LD = *FIXME*

CLFAGS = $(LDFLAGS)
FFLAGS = $(LDFLAGS)
LDFLAGS = -g -O5 -qarch=450d -qtune=450 -qsuppress=cmpmsg
