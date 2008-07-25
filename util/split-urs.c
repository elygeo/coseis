// Split URS Graves format
#include <stdio.h>
#include <stdlib.h>
#define INT_SIZE 4
#define FLOAT_SIZE 4

int main( int argc, char** argv ) {
  FILE* input = fopen( argv[1], "rb" );
  FILE* v1 = fopen( "v1", "wb" );
  FILE* v2 = fopen( "v2", "wb" );
  FILE* v3 = fopen( "v3", "wb" );
  int i, nx, ny, nz, nt, n, it;
  float x;
  float* vv;
  fseek( input, 0, SEEK_SET );
  fread( &i, INT_SIZE, 1, input ); printf( "ix0: %d\n", i );
  fread( &i, INT_SIZE, 1, input ); printf( "iy0: %d\n", i );
  fread( &i, INT_SIZE, 1, input ); printf( "iz0: %d\n", i );
  fread( &i, INT_SIZE, 1, input ); printf( "it0: %d\n", i );
  fread( &nx, INT_SIZE, 1, input ); printf( "nx: %d\n", nx );
  fread( &ny, INT_SIZE, 1, input ); printf( "ny: %d\n", ny );
  fread( &nz, INT_SIZE, 1, input ); printf( "nz: %d\n", nz );
  fread( &nt, INT_SIZE, 1, input ); printf( "nt: %d\n", nt );
  fread( &x, FLOAT_SIZE, 1, input ); printf( "dx: %f\n", x );
  fread( &x, FLOAT_SIZE, 1, input ); printf( "dy: %f\n", x );
  fread( &x, FLOAT_SIZE, 1, input ); printf( "dz: %f\n", x );
  fread( &x, FLOAT_SIZE, 1, input ); printf( "dt: %f\n", x );
  fread( &x, FLOAT_SIZE, 1, input ); printf( "rot: %f\n", x );
  fread( &x, FLOAT_SIZE, 1, input ); printf( "lat: %f\n", x );
  fread( &x, FLOAT_SIZE, 1, input ); printf( "lon: %f\n", x );
  n = nx * ny * nz;
  vv = malloc( n * sizeof( float ) );
  if ( vv == NULL) { printf( "Malloc error.\n" ); exit(1); }
  fseek( input, 60, SEEK_SET );
  for ( it = 1; it <= nt; it++ ) {
    printf( "%d\n", it );
    fread( vv, FLOAT_SIZE, n, input ); fwrite( vv, FLOAT_SIZE, n, v1 );
    fread( vv, FLOAT_SIZE, n, input ); fwrite( vv, FLOAT_SIZE, n, v2 );
    fread( vv, FLOAT_SIZE, n, input ); fwrite( vv, FLOAT_SIZE, n, v3 );
  }
  fclose( input );
  fflush( v1 ); fclose( v1 );
  fflush( v2 ); fclose( v2 );
  fflush( v3 ); fclose( v3 );
  return 0;
}

