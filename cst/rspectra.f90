! Response Spectra
!
! Original code by Doug Dreger
! Wrapper by Geoffrey Ely
!
! Create Python module with:
!     f2py -c -m rspectra rspectra.f90
!
! real component of displacement spectrum:    rd = z(1)
! real component of velocity spectrum:        rv = z(2)
! real component of acceleration spectrum:    aa = z(3)
! imaginary component of velocity spectrum:   prv = w * z(1)
! imaginary component of velocity spectrum:   pra = w * prv
! imaginary vel = i*w* real displacement
! imaginary acc = i*w* real velocity    

! Wrapper
! u  : acceleration time history
! dt : time step length
! w  : angular frequency = 2 pi / T
! d  : damping ratio
! n  : number of samples (automatically determined)
subroutine rspectra( z, u, dt, w, d, n )
implicit none
real, intent(out) :: z(3)
real, intent(in) :: u(n), dt, w, d
integer, intent(in) :: n
!f2py intent(hide) :: n
if ( w > 0.4 * acos(0.0) / dt ) then
    call ucmpmx( z, u, dt, w, d, n-1 )
else
    call cmpmax( z, u, dt, w, d, n-1 )
end if
end subroutine

! Use when period >= 10.0 * dt
!     subroutine cmpmax(dur1,kug,ug,pr,w,d,dt,z)
!     real ug(*),x(2,3),t(3),z(*),c(3)
      subroutine cmpmax(z,ug,dt,w,d,kug)
      real ug(*),x(2,3),z(3),c(3)
      wd=sqrt(1.-d*d)*w
      w2=w*w
      w3=w2*w
      do 10 i=1,3
        x(1,i)=0.
10       z(i)=0.
      f1=2.*d/(w3*dt)
      f2=1./w2
      f3=d*w
      f4=1./wd
      f5=f3*f4
      f6=2.*f3
      e=exp(-f3*dt)
      g1=e*sin(wd*dt)
      g2=e*cos(wd*dt)
      h1=wd*g2-f3*g1
      h2=wd*g1+f3*g2
      do 100 k=1,kug
        dug=ug(k+1)-ug(k)
        z1=f2*dug
        z2=f2*ug(k)
        z3=f1*dug
        z4=z1/dt
        b=x(1,1)+z2-z3
        a=f4*x(1,2)+f5*b+f4*z4
        x(2,1)=a*g1+b*g2+z3-z2-z1
        x(2,2)=a*h1-b*h2-z4
        x(2,3)=-f6*x(2,2)-w2*x(2,1)
        do 80 l=1,3
          c(l)=abs(x(2,l))
          if(c(l).gt.z(l)) then
            z(l)=c(l)
!           t(l)=dt*real(k)+dur1
          ENDif
80        x(1,l)=x(2,l)
100     CONTINUE
!     write(6,1) pr,(t(l),l=1,3)
!     return
!     format(' cmpmax t=',f6.3,' td = ',f8.4,' tv = ',f8.4,' ta = ',
!    , f8.4)
      end subroutine

! Use when period < 10.0 * dt
!     subroutine ucmpmx(dur1,kug,ug,time,pr,w,d,z)
!     real ug(*),time(*),z(*),t(3),c(3),x(2,3)
      subroutine ucmpmx(z,ug,dt0,w,d,kug)
      real ug(*),z(3),c(3),x(2,3)
      pr = 4.0 * acos( 0.0 ) / w
      wd=sqrt(1.-d*d)*w
      w2=w*w
      w3=w2*w
      do 10 i=1,3
        x(1,i)=0.
 10     z(i)=0.
      f2=1./w2
      f3=d*w
      f4=1./wd
      f5=f3*f4
      f6=2.*f3
!     do 100 k=1,kug
!       dt=time(k+1)-time(k)
        dt=dt0
        ns=nint(10.*dt/pr)+1
        dt=dt/real(ns)
        f1=2.*d/w3/dt
        e=exp(-f3*dt)
        g1=e*sin(wd*dt)
        g2=e*cos(wd*dt)
        h1=wd*g2-f3*g1
        h2=wd*g1+f3*g2
      do 100 k=1,kug
        dug=(ug(k+1)-ug(k))/real(ns)
        g=ug(k)
        z1=f2*dug
        z3=f1*dug
        z4=z1/dt
        do 100 is=1,ns
          z2=f2*g
          b=x(1,1)+z2-z3
          a=f4*x(1,2)+f5*b+f4*z4
          x(2,1)=a*g1+b*g2+z3-z2-z1
          x(2,2)=a*h1-b*h2-z4
          x(2,3)=-f6*x(2,2)-w2*x(2,1)
          do 80 l=1,3
            c(l)=abs(x(2,l))
            if(c(l).gt.z(l)) then
              z(l)=c(l)
!             t(l)=time(k)+is*dt+dur1
            ENDif
80          x(1,l)=x(2,l)
          g=g+dug
100       CONTINUE
!     write(6,1) pr,(t(l),l=1,3)
!     return
!     format(' ucmpmx t=',f6.3,' td = ',f8.4,' tv = ',f8.4,' ta = ',
!    , f8.4)
      end subroutine

