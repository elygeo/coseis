// CVM-S Mesher
// Can be run concurrently for each file (3 processes).

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>

void error(char *message) {
    printf("Error: %s\n", message);
    exit(1);
}

int main(int argc, char *argv[]) {

const float z_start = Z_START, delta = DELTA;
const size_t m = SHAPE_X, n = SHAPE_Z;
const size_t b = sizeof(float);
const int flags = O_WRONLY | O_CREAT | O_EXCL;
const int mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
float x[m];
size_t i, j;
int fh;
FILE *f;

// longitude
if ((fh = open("hold/lon.bin", flags, mode)) >= 0) {

    // read 2D
    if ((f = fopen("lon.bin", "r")) == NULL)
        error("lon fopen");
    if (fread(x, b, m, f) != m)
        error("lon fread");
    if (fclose(f))
        error("lon fclose");

    // write 3D
    if ((f = fdopen(fh, "w")) == NULL)
        error("lon fdopen");
    for (j = 0; j < n; j++)
        if (fwrite(x, b, m, f) != m)
            error("lon fwrite");
    if (fclose(f))
        error("lon fclose");
}

// latitude
if ((fh = open("hold/lat.bin", flags, mode)) >= 0) {

    // read 2D
    if ((f = fopen("lat.bin", "r")) == NULL)
         error("lat fopen");
    if (fread(x, b, m, f) != m)
         error("lat fread");
    if (fclose(f))
         error("lat fclose");

    // write 3D
    if ((f = fdopen(fh, "w")) == NULL)
         error("lat fdopen");
    for (j = 0; j < n; j++)
        if (fwrite(x, b, m, f) != m)
            error("lat fwrite");
    if (fclose(f))
         error("lat fclose");
}

// depth
if ((fh = open("hold/dep.bin", flags, mode)) >= 0) {
    if ((f = fdopen(fh, "w")) == NULL)
        error("dep fdopen");
    for (j = 0; j < n; j++) {
        for (i = 0; i < m; i++)
            x[i] = z_start + j * delta;
        if (fwrite(x, b, m, f) != m)
            error("dep fwrite");
    }
    if (fclose(f))
        error("dep fclose");
}

// all done
return 0;

}

