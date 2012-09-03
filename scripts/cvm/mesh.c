// CVM-S Mesher
// Reads 2D mesh files and extends them to 3D.
// Can be run concurrently for each file (3 processes).

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[]) {

const int flags = O_WRONLY | O_CREAT | O_EXCL;
const int mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
const float z_start = Z_START, delta = DELTA;
const size_t m = SHAPE_X, n = SHAPE_Z;
const size_t b = sizeof(float);
float *x = (float *)malloc(m * b);
int fh, e;
size_t i, j;
FILE *f;

// longitude
fh = open("hold/lon.bin", flags, mode);
if (fh >= 0) {
    f = fopen("lon.bin", "r");
    e = f == NULL || fread(x, b, m, f) != m;
    e = fclose(f) || e;
    f = fdopen(fh, "w");
    e = f == NULL || e;
    for (j = 0; j < n; j++) {
        if (e) break;
        e = fwrite(x, b, m, f) != m;
    }
    e = fclose(f) || e;
    if (e) {
        remove("hold/lon.bin");
        printf("Error in lon file\n");
    }
}

// latitude
fh = open("hold/lat.bin", flags, mode);
if (fh >= 0) {
    f = fopen("lat.bin", "r");
    e = f == NULL || fread(x, b, m, f) != m;
    e = fclose(f) || e;
    f = fdopen(fh, "w");
    e = f == NULL || e;
    for (j = 0; j < n; j++) {
        if (e) break;
        e = fwrite(x, b, m, f) != m;
    }
    e = fclose(f) || e;
    if (e) {
        remove("hold/lat.bin");
        printf("Error in lat file\n");
    }
}

// depth
fh = open("hold/dep.bin", flags, mode);
if (fh >= 0) {
    f = fdopen(fh, "w");
    e = f == NULL;
    for (j = 0; j < n; j++) {
        if (e) break;
        for (i = 0; i < m; i++) x[i] = z_start + j * delta;
        e = fwrite(x, b, m, f) != m;
    }
    e = fclose(f) || e;
    if (e) {
        remove("hold/dep.bin");
        printf("Error in dep file\n");
    }
}

// all done
return 0;

}

