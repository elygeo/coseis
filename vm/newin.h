! newin.h - memory usage is ibig*37*4 bytes
      integer, parameter :: ibig = 4194304
      real, parameter :: rdepmin = 0.
      common /oi/ rlat, rlon, rdep, alpha, beta, rho, inout, nn, nnl
      real :: rlat(ibig), rlon(ibig), rdep(ibig), alpha(ibig), 
     $  beta(ibig), rho(ibig)
      integer :: inout(ibig), nn, nnl
