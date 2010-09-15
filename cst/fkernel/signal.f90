! This is a module containing subroutines for signal processing in Fortran 90
! On kraken, pay attention to the array argument to a subroutine

! Updated on 01.11.2010
!
module signal
   !use global
   implicit none

contains
    
    ! nextpow2
    subroutine nextpow2(ni,nn,pow2)
        integer :: ni, nn, pow2
        pow2 = 1
        nn = 2**pow2
        do while( ni.ge.nn )
            pow2 = pow2 + 1
            nn = 2**pow2
        end do 
    end subroutine nextpow2
    
    ! reverse 1D array
    subroutine reverse( a )
        ! input
        ! a: 1D real array
        ! ouput
        ! a: 1D array which is reversed from input a
        real, dimension(:) :: a
        real :: tmp
        integer :: n, n2, i
      
        n = size(a)
        n2 = int( n/2 )
        do i = 1,n2
            tmp = a(i)
            a(i) = a(n-i+1)
            a(n-i+1) = tmp
        enddo
        return
        
    end subroutine reverse
  
    ! FFT
    subroutine fft( ur,ui,nn,flag )
        ! input
        ! ur, ui: real part and imaginary part
        ! nn: 2**n2
        ! flag=1: time to frequency; flag=-1: freqency to time
        
        ! output
        ! uri with length 2*nn

        integer :: nn, n, flag, i, j, m, mm, mmax, istep
        real :: tmpr, tmpi, theta, wpr, wpi, wr, wi, wtmp, on,pi
        real, dimension(:), allocatable :: uri
        real, dimension(:) :: ur, ui

        
        pi = 4.0*atan(1.0)
        n  = 2*nn

        allocate(uri(n))
        uri = 0.0
        do i = 1,nn
            uri(2*i-1) = ur(i)
            uri(2*i)   = ui(i)
        enddo
        
        !!!!!!!!!!!!!!!!!!!!!!!!!   wrapping  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        j = 1
        do i = 1, n,2
             if( j.gt.i )then
                 tmpr  = uri(j)
                 tmpi  = uri(j+1)
                 uri(j) = uri(i)
                 uri(j+1) = uri(i+1)
                 uri(i) = tmpr
                 uri(i+1) = tmpi
             end if
             mm = n/2
             do while( mm.ge.2 .and. j.gt.mm )
                  j = j-mm
                  mm = mm/2
             end do
             j = j+mm
        end do
        ! finish wrapping ( debug: correct )

        ! FFT 
        mmax = 2
        do while( n.gt.mmax )    ! outer loop execute log(2,nn) times
            istep = 2*mmax

            ! initialize for the trigonometric recurrence
            theta = 2*pi/(flag*mmax)
            wpr = -2.d0*sin(0.5d0*theta)**2
            wpi = sin(theta)
            wr = 1.d0
            wi = 0.d0

            ! two nested inner loops
            do m = 1,mmax,2
                do i = m,n,istep
                    j = i+mmax
                    tmpr = wr*uri(j)  - wi*uri(j+1)
                    tmpi = wr*uri(j+1)+ wi*uri(j)
                    
                    uri(j) = uri(i)-tmpr
                    uri(j+1) = uri(i+1)-tmpi
                    
                    uri(i) = uri(i)+tmpr
                    uri(i+1) = uri(i+1) +tmpi

                enddo
                wtmp = wr    ! trigonometric recurrence
                wr = wr*wpr-wi*wpi+wr
                wi = wi*wpr+wtmp*wpi+wi
            enddo
            mmax = istep
        enddo 

        if( flag .eq. -1 )then
            on = 1.0/nn
            uri = on*uri
        end if

        do i = 1,nn
            ur(i) = uri(2*i-1)
            ui(i) = uri(2*i)
        enddo   
        
        deallocate(uri)
        
        return
    end subroutine fft
 
    ! convlv using FFT
    subroutine convlv( u1, u2, uc )
        ! input
        ! u1: input series
        ! u2: input series
        ! output
        ! uc: convolution between u1 and u2
        integer :: n1, n2, n, i, pow2, nfft, flag
        real, dimension(:),allocatable :: u1rpad, u1ipad, &
                          &u2rpad, u2ipad,  ucrpad, ucipad
        real, dimension(:) :: u1,u2,uc
        
        n1 = size( u1 )
        n2 = size( u2 )
        n = n1+n2-1
         
        call nextpow2(n,nfft,pow2)
        allocate( u1rpad(nfft), u1ipad(nfft), u2rpad(nfft),u2ipad(nfft),&
                  &ucrpad(nfft),ucipad(nfft) )
        u1rpad = 0.0
        u1ipad = 0.0
        u2rpad = 0.0
        u2ipad = 0.0
        ucrpad = 0.0
        ucipad = 0.0
        
        u1rpad(1:n1) = u1(1:n1)
        u2rpad(1:n2) = u2(1:n2)
        flag = 1
        call fft(u1rpad,u1ipad,nfft,flag)
        call fft(u2rpad,u2ipad,nfft,flag)
        
        ucrpad = real( cmplx(u1rpad, u1ipad)*cmplx(u2rpad,u2ipad) )
        ucipad = imag( cmplx(u1rpad, u1ipad)*cmplx(u2rpad,u2ipad) )

        flag = -1
        call fft(ucrpad,ucipad,nfft,flag)
        
        ! take first n elements for uc
        do i = 1,n
            uc(i) = ucrpad(i)
        enddo
        
        deallocate(u1rpad,u1ipad,u2rpad,u2ipad,ucrpad,ucipad)
        
        return 
    
    end subroutine convlv
    
    subroutine convlv_t( a, b )
        integer :: i,j,k,p,r,s,la,lb
        real :: tmp
        real, dimension(:) :: a,b
        real, dimension(:), allocatable :: c
        
        la = size(a) 
        lb = size(b) 
        p = la - 1
        k = lb - 1
        allocate(c(1:p+k+1))
        do j = p+k,0,-1
            s = min(j,p)
            r = max(0,j-k)
            tmp = 0.0
            do i = r,s,1
                tmp = tmp + a(i+1)*b(j-i+1)
            enddo
            c(j+1) = tmp
        enddo
        a(1:la) = c(1:la)
        deallocate(c)
        return
    end subroutine convlv_t
    
    ! compute cross-correlation between u1 and u2 by using convlv method
    subroutine xcorr( u1, u2, ux )
        ! input
        ! u1, u2: 1D real series
        ! ouput
        ! ux
        real, dimension(:) :: u1, u2, ux
        
        call reverse( u2 )
        call convlv( u1, u2, ux )
        return

    end subroutine xcorr

    subroutine x_corr( u1, u2, ux)    ! tmp corr

        integer :: n1, n2, n, i, pow2, nfft, flag
        real, dimension(:),allocatable :: u1rpad, u1ipad, &
                          &u2rpad, u2ipad,  uxrpad, uxipad
        real, dimension(:) :: u1,u2,ux

        
        n1 = size( u1 )
        n2 = size( u2 )
        n = n1+n2-1
         
        call nextpow2(n,nfft,pow2)
        allocate( u1rpad(nfft), u1ipad(nfft), u2rpad(nfft),u2ipad(nfft),&
                  &uxrpad(nfft),uxipad(nfft) )
        u1rpad = 0.0
        u1ipad = 0.0
        u2rpad = 0.0
        u2ipad = 0.0
        uxrpad = 0.0
        uxipad = 0.0
        
        u1rpad(1:n1) = u1(1:n1)
        u2rpad(1:n2) = u2(1:n2)
        flag = 1
        call fft(u1rpad,u1ipad,nfft,flag)
        call fft(u2rpad,u2ipad,nfft,flag)

        uxrpad = real( cmplx(u1rpad, u1ipad)*conjg( cmplx(u2rpad,u2ipad) ) )
        uxipad = imag( cmplx(u1rpad, u1ipad)*conjg( cmplx(u2rpad,u2ipad) ) )

        flag = -1
        call fft(uxrpad,uxipad,nfft,flag)
        
        do i = 1,n
            ux(i) = uxrpad(i)
        enddo
        ! wrapping
        !di i = 1,n
        deallocate(u1rpad,u1ipad,u2rpad,u2ipad,uxrpad,uxipad)
        
        return 
    
    end subroutine x_corr


    !!!!!!!!!!!!!!!!!!!!!! numerical recipe method for fft   !!!!!!!!!!!!!!!!!!!
    
    ! numerical recipe fft with complex array input
    subroutine cfft( uc, nn, flag )
        ! input
        ! uc: complex input serise with length nn
        !      uc(i) = cmplx( ur(i), ui(i) )
        ! nn: 2**n2
        ! flag=1: time to frequency; flag=-1: freqency to time
        
        ! output
        ! uri with length 2*nn


        integer :: nn, n, flag, i, j, m, mm, mmax, istep
        real*8 :: pi, tmpr, tmpi, theta, wpr, wpi, wr, wi, wtmp, on
        real, dimension(:), allocatable :: uri
        complex, dimension(:) :: uc

        pi = 4.0*atan(1.0)
        n  = 2*nn

        !!!!!!!!!!!!!!!!!!!!!!!!!   wrapping  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        allocate( uri(n) )
        do i = 1,nn
            uri(2*i-1) = real( uc(i) )
            uri(2*i) = aimag( uc(i) )
        enddo

        j = 1
        do i = 1,n,2
            if( j.gt.i )then
                tmpr = uri(j)
                tmpi = uri(j+1)
                uri(j) = uri(i)
                uri(j+1)=uri(i+1)
                uri(i) = tmpr
                uri(i+1) = tmpi
            endif
            mm = n/2
            do while( mm.ge.2 .and. j.gt.mm ) 
                j = j-mm
                mm = mm/2
            enddo
            j = j+mm
        enddo
        ! finish wrapping ( debug: correct )
        
        ! FFT 
        mmax = 2
        do while( n.gt.mmax )    ! outer loop execute log(2,nn) times
            istep = 2*mmax

            ! initialize for the trigonometric recurrence
            theta = 2*pi/(flag*mmax)
            wpr = -2.d0*sin(0.5d0*theta)**2
            wpi = sin(theta)
            wr = 1.d0
            wi = 0.d0

            ! two nested inner loops
            do m = 1,mmax,2
                do i = m,n,istep
                    j = i+mmax
                    tmpr = wr*uri(j)  - wi*uri(j+1)
                    tmpi = wr*uri(j+1)+ wi*uri(j)
                    
                    uri(j) = uri(i)-tmpr
                    uri(j+1) = uri(i+1)-tmpi
                    
                    uri(i) = uri(i)+tmpr
                    uri(i+1) = uri(i+1) +tmpi

                enddo
                wtmp = wr    ! trigonometric recurrence
                wr = wr*wpr-wi*wpi+wr
                wi = wi*wpr+wtmp*wpi+wi
            enddo
            mmax = istep
        enddo 

        if( flag .eq. -1 )then
            on = 1.0/nn
            uri = on*uri
        end if
        do i = 1,nn
            uc(i) = cmplx( uri(2*i-1), uri(2*i) )
        enddo
        
        deallocate( uri )

        return  ! complex array uc

    end subroutine cfft

end module signal
        



    
    
    
        
