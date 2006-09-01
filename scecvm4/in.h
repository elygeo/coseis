c  in.h   contains i-o stuff
         integer(8) nn
         parameter(ibig=4000000, rdepmin=0.0)
         common /oi/nn,rlat(ibig),rlon(ibig),rdep(ibig),
     1   alpha(ibig),beta(ibig),rho(ibig),inout(ibig)
