CC = clang
LDFLAGS = -g -O3 -Wall -pedantic
CFLAGS = $(LDFLAGS) \
    -DNZ={nz} \
    -DNNODE={nnode} \
    -DDELTA={delta} \
    -DZSTART={zstart}

mesh.x: mesh.c Makefile
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -rf run mesh.x mesh.x.dSYM

