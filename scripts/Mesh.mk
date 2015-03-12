CC = clang
LDFLAGS = -g -O3 -Wall -pedantic
CFLAGS = $(LDFLAGS) \
    -DNZ={nz} \
    -DNNODE={nnode} \
    -DDELTA={delta} \
    -DZSTART={zstart}

mesh.x: Mesh.c Mesh.mk
	$(CC) $(CFLAGS) -o $@ $<

