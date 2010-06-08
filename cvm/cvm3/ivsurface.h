c  ivsurface.h   contains Imperial Valley reference surface info
c
c ibig  = max number points to define model at
c numsiv= number of reference surfaces
c mxsur = max number of lat and long in reference surfaces
c mxedge= max number of lat-long pairs defining surface edges
c ivi3    = number of model edge points
c ivi2    = number of Imp Valley edge points
c ibg   = number layers/interfaces of background model
         parameter(numsiv=6,mxedge=10,mxsur=121)
         parameter (ivi3=5,ibg=5,ivi2=102)
         common /ivin/ ivinot(ibig)
         common /rsivfs/rlosiv(numsiv,mxsur),rlasiv(numsiv,mxsur),
     1   nlosiv(numsiv),nlasiv(numsiv),rsuvil(numsiv,mxsur,mxsur),
     2   rckval,rv(numsiv)
         common /edgesiv/ nedgeiv(numsiv), rtxiv(numsiv,mxedge),
     1   rtyiv(numsiv,mxedge)
         common/rmedgeiv/rmoivx(ivi3),rmoivy(ivi3)
         common/rivdge/rivvax(ivi2),rivvay(ivi2)
