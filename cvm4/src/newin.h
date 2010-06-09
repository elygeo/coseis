! newin.h - memory usage is ibig*38*4 bytes
!     integer, parameter :: ibig = 4194304
      integer, parameter :: ibig = 4507502
      real, parameter :: rdepmin = 0.
      common /oi/ rlat, rlon, rdep, alpha, beta, rho, inout, nn, nnl
      real :: rlat(ibig), rlon(ibig), rdep(ibig), alpha(ibig), 
     $  beta(ibig), rho(ibig)
      integer :: inout(ibig), nn, nnl
