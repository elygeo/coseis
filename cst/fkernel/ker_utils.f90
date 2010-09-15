! module containing the utils to compute seismogram perturbation kernel J(t)
module ker_utils
    ! use global
    use signal

    implicit none
    contains

    subroutine dudt(u,n,h,v)
        
        integer :: n, i
        real :: h, h1, u(:),v(:)
        
        h1 = 1./(2.*h)
        do i = 2,n-1
            v(i) = (u(i+1)-u(i-1))*h1
        enddo
        v(1) = u(2)*h1
        v(n) = -u(n-1)*h1
        
        return 
        
    end subroutine dudt 


    subroutine FiWKernel(riDt, isf, dt, sigma_w, omega_i, sigma_i, flag_dtx)
        !input:
        ! isf: isolation filter
        ! dt : the sample interval of synthetic
        ! sigma_w: half-width of the time window
        ! omega_i: central frequency of the narrow-band filter
        ! sigma_i: half-width of the narrow-band filter
        ! flag_dtx: 1,dtp; 0, dtq
        !output:
        ! riDT: the real (for dtq) and imaginary(for dtp) part of Di(t) or J(t)

        integer :: npts, flag_dtx, ii, iw, flag_fft, nfft, n2
        real, dimension(:) :: riDt, isf
        real, dimension(:), allocatable :: isf_v

        real :: dt, sigma_w, omega_i, sigma_i

        double precision :: pi,omega, df, fmax, sigma1, sigma2, anorm
        double precision, dimension(:), allocatable :: omega1, omega2, Aw
        complex, dimension(:), allocatable :: isf_f, isf_fc, isf_fc1

        omega = 0.0
        pi = 4.0*atan(1.0)
        npts = size(isf)
        call nextpow2( npts, nfft, n2 )

        if ( sigma_i .gt. 0 ) then
            
            allocate( omega1(nfft), omega2(nfft), Aw(nfft), isf_f(nfft),&
                      isf_fc(nfft), isf_fc1(nfft) )
            
            fmax = 0.5d0/dt   ! Nyquist frequency
            df = fmax/(nfft/2.0d0)   ! frequency domain sampling interval
            !df = 1.0d0/(nfft*dt)
            sigma1 = sigma_w**2 + sigma_i**2   ! sigma' 
            sigma2 = sqrt( sigma_w**2 * sigma_i**2 / sigma1 )
            
            do ii = 1, nfft/2
                omega = (ii-1)*df*2.d0*pi
                omega1(ii) = (sigma_i**2*omega+sigma_w**2*omega_i)/sigma1
                omega2(ii) = (sigma_i**2*omega-sigma_w**2*omega_i)/sigma1
            enddo
            
            do ii = 1,npts
                isf_f(ii) = cmplx( isf(ii), 0.d0 )
            enddo
            do ii = npts+1, nfft
                isf_f(ii) = cmplx( 0.d0, 0.d0 )
            enddo

            flag_fft = 1
            call cfft( isf_f, nfft, flag_fft )
            ! debug this:
            do ii = 1,nfft
                ! A~ ( auto-correlation )
                Aw(ii) = abs(conjg(isf_f(ii))*isf_f(ii))/nfft
            enddo
            iw = nint( omega_i/(df*2*pi) )+1   ! index of the dominant frequency
            
            ! compute narrow-band J(t)
            if (flag_dtx.eq.0) then   ! dtq
                do ii = 1,nfft/2   ! positive frequency
                    omega = (ii-1)*df*2.0d0*pi
                    isf_fc(ii) = conjg(isf_f(ii))/omega1(ii)* &
                                 exp(-0.5d0*(omega-omega_i)**2/(2*sigma1))
                    isf_fc1(ii) = conjg(isf_f(ii))/abs(omega2(ii))* &
                                 exp(-0.5d0*(omega+omega_i)**2/(2*sigma1))
                enddo
                do ii = nfft/2+1,nfft
                    isf_fc(ii) = cmplx(0.d0,0.d0)
                    isf_fc1(ii) = cmplx(0.d0,0.d0)
                enddo
                
                flag_fft = -1
                call cfft( isf_fc, nfft, flag_fft )
                call cfft( isf_fc1, nfft, flag_fft )

                anorm = sigma2/sigma_w/Aw(iw)
                do ii = 1,npts
                    riDt(ii) = (-dble(isf_fc(ii))-dble(isf_fc1(ii)))*anorm
                enddo

            else if (flag_dtx .eq. 1 )then  ! dtp
                do ii = 1,nfft/2
                    isf_fc(ii) = conjg(isf_f(ii))/omega1(ii)* &
                                 exp(-0.5d0*(omega-omega_i)**2/(2*sigma1))
                    isf_fc1(ii) = conjg(isf_f(ii))/omega2(ii)* &
                                 exp(-0.5d0*(omega+omega_i)**2/(2*sigma1))
                enddo
                do ii = nfft/2+1, nfft
                    isf_fc(ii) = cmplx(0.d0,0.d0)
                    isf_fc1(ii) = cmplx(0.d0,0.d0)
                enddo

                flag_fft = -1
                call cfft( isf_fc, nfft, flag_fft )
                call cfft( isf_fc1, nfft, flag_fft )

                anorm = sigma2/sigma_w/Aw(iw)
                do ii = 1,npts
                    riDt(ii) = (aimag(isf_fc(ii))+aimag(isf_fc1(ii)))*anorm
                enddo
            else
                print *, 'flag_dtx should be 1(tp) or 0(tq)...'
            end if
            deallocate( omega1,omega2,Aw,isf_f,isf_fc,isf_fc1)
        
        
        else   ! Broad-band J(t)
            ! isolation filter comes from displacement
            anorm = 0.0
            if (flag_dtx.eq.1)then   ! dtp
                
                allocate(isf_v(npts))
                isf_v = 0
                
                call dudt( isf, npts, dt, isf_v ) 
                
                do ii = 1,npts
                    riDt(ii) = -isf_v(ii)
                    anorm = anorm+riDt(ii)**2
                enddo
                
                !riDt(1) = 0.0
                !do ii = 2, npts
                    ! debug
                !    riDt(ii) = -(isf(ii)-isf(ii-1))/dt
                !    anorm = anorm + riDt(ii)**2
                !enddo
            else if (flag_dtx .eq. 0)then   ! dtq
                do ii = 1, npts 
                    riDt(ii) = -isf(ii)
                    anorm = anorm + riDt(ii)**2
                enddo
            else
                print *, 'flag_dtx should be 0(dtq) or 1(dtp)...'
            end if
            riDt = riDt/(anorm*dt)

        end if

        return

    end subroutine FiWKernel

end module ker_utils
