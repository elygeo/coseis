#if ( itstats < 1 ) itstats = itstats + nt + 1
#if ( itio    < 1 ) itio    = itio    + nt + 1
#if ( itcheck < 1 ) itcheck = itcheck + nt + 1
#if ( modulo( itcheck, itio ) /= 0 ) itcheck = ( itcheck / itio + 1 ) * itio

i! Time indices
if ( p%i1(4) < 0 ) p%i1(4) = nt + p%i1(4) + 1
if ( p%i2(4) < 0 ) p%i2(4) = nt + p%i2(4) + 1
if ( p%di(4) < 0 ) p%di(4) = nt + p%di(4) + 1
p%i2(4) = min( p%i2(4), nt )
p%i3(4) = p%i1(4) FIXME
p%i4(4) = 0 FIXME

zones

