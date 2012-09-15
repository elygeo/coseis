CC = clang
LIBS = 
CFLAGS = -g -O3 -Wall -pedantic \
    -DNX=32 \
    -DNY=28 \
    -DNZ=12 \
    -DDELTA=4000.0 \
    -DNPML=2 \
    -DNTOP=6

mesh.x : mesh.c Makefile
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)

clean :
	rm -rf run mesh.x mesh.x.dSYM

