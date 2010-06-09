#!/usr/bin/env python
import os

def rspec():
    cwd = os.getcwd()
    path = os.path.realpath( os.path.dirname( __file__ ) )
    os.chdir( path )
    if not os.path.isfile( 'rspectra.so' ):
        os.system( 'f2py -c -m rspectra rspectra.f90' )
    os.chdir( cwd )

if __name__ == '__main__':
    rspec()

