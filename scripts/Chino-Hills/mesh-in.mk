# Mesher Makefile

mesh.x : mesh.c Makefile
	$(CC) $(CFLAGS) $(CVMFLAGS) -o $@ $<

clean :
	rm -rf run mesh.x mesh.x.dSYM

# Options
MACHINE = {machine}
CFLAGS = \
    -DNX={nx} \
    -DNY={ny} \
    -DNZ={nz} \
    -DDELTA={delta} \
    -DNPML={npml} \
    -DNTOP={ntop}

# Default: GNU Compiler Collection
CC = gcc
CFLAGS += -g -O3 -Wall -pedantic

# ALCF IBM Blue Gene/Q
ifeq ($(MACHINE), ALCF-BGQ)
    CC = mpixlc_r
    CFLAGS += -g -O3 -qsuppress=cmpmsg -qlist -qreport
endif

