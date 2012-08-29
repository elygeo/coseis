// CVM-S Mesher
// May be run concurrently for each file (3 processes).

#include <stdio.h>
#include <fcntl.h>

int main(void) {

const float z_start = Z_START, delta = DELTA;
const size_t m = SHAPE_X, n = SHAPE_Z;
const size_t b = sizeof(float);
const int mode = O_WRONLY | O_CREAT | O_EXCL;
float x[m];
size_t i, j;
int fh;
FILE *f;

// write longitude file
if ((fh = open("hold/lon.bin", mode)) > 0) {
    f = fopen("lon.bin", "r");
    i = fread(x, m, b, f);
    fclose(f);
    if (f == NULL || i != m) {
        perror("read error");
        return 1;
    }
    f = fdopen(fh, "w");
    for (j = 0; j < n; j++)
        if (fwrite(x, m, b, f) != m) {
            perror("write error");
            return 1;
        }
}

// write latitude file
if ((fh = open("hold/lat.bin", mode)) > 0) {
    f = fopen("lat.bin", "r");
    i = fread(x, m, b, f);
    fclose(f);
    if (f == NULL || i != m) {
        perror("read error");
        return 1;
    }
    f = fdopen(fh, "w");
    for (j = 0; j < n; j++)
        if (fwrite(x, m, b, f) != m) {
            perror("write error");
            return 1;
        }
}

// write depth file
if ((fh = open("hold/dep.bin", mode)) > 0) {
    f = fdopen(fh, "w");
    for (j = 0; j < n; j++) {
        for (i = 0; i < m; i++)
            x[i] = z_start + j * delta;
        if (fwrite(x, m, b, f) != m) {
            perror("write error");
            return 1;
        }
    }
}

// all done
return 0;

}

