! program to compute Frechet kernels
! version 0.2
! Feng Wang
! 02/11/2010

program cpt_ker

! use module
use mpi
use ker_utils

! #ifdef MPI
! use mpi
! #endif

! variables declaration:
implicit none
integer :: i, ii
integer :: bsize, varnum(1), ehsize
real :: pi

character(len=200) :: input, xyzgrd,pxyzgrd,Ppth,Spth,Rpth,&
                      ewfin,sgtin,ewfout(6),sgtout1(6),sgtout2(6),sgtout3(6),&
                      isfpth,fdpth,jtpth,kerpth
character(len=80) :: ssc
integer :: nt, cmpid, xgs, ygs, zgs, xgr, ygr, zgr
real :: dt,dx1,dx2,dx3

real, dimension(:), allocatable :: stf_im
real :: maxtmp
integer :: itshift

integer :: it
real :: t1, t2, delta, npts, t0 
real, dimension(:), allocatable :: tmpzero, isf

integer :: nfreq
real :: par_sigmai, par_sigmaw
real, dimension(:), allocatable :: freq

integer :: it1, it2, ifreq
real :: sigma_w, omega_i, sigma_i
real, dimension(:), allocatable :: riDt
real, dimension(:,:), allocatable :: rDt,iDt

integer :: nnx, nny, nnz, ncx, ncy, ncz, nngrd, ncgrd
integer :: nlgrd, nxt, nyt, nzt, offset
integer :: nn(3), np3(3), nl(3)
character(len=6) :: procid
character(len=9) :: pxyzid

character(len=200) :: ewftmp, sgttmp
real, dimension(:), allocatable :: Vp, Vs, Rho
real, dimension(:,:,:), allocatable :: e_ij, h_ijm

integer :: it_1, it_2
real, dimension(:), allocatable :: b,tmp1,tmp2,&
                                   tmpap,tmpaq,tmpbp,tmpbq
real, dimension(:,:), allocatable :: kap,kaq,kbp,kbq

integer :: rank, psize, err, npx, npy, npz, ipx, ipy, ipz
integer, dimension(:,:,:), allocatable :: pidmap
character(len=6) :: rankchar

! write seperated kernel files in to one single binary file
! 
integer :: stats(MPI_STATUS_SIZE)
integer :: buf_size, r_size
integer, dimension(:), allocatable :: fpoint1, fpoint2, fpoint3, fpoint4
character(len=1) :: freqc
integer(KIND=MPI_OFFSET_KIND) :: disp   
real, dimension(:), allocatable :: ker_buf

call MPI_INIT(err)
call MPI_COMM_RANK(MPI_COMM_WORLD,rank,err)
call MPI_COMM_SIZE(MPI_COMM_WORLD,psize,err)


bsize = 4*size(varnum)
inquire(iolength=bsize)varnum
!print*,bsize
pi = 4.0*atan(1.0)

! 1.1 read input files
call getarg(1,input)
open(11,file=input,form='formatted')
read(11,'(a)')xyzgrd
read(11,'(a)')pxyzgrd
read(11,'(a)')Ppth
read(11,'(a)')Spth
read(11,'(a)')Rpth
read(11,'(a)')ewfin
read(11,'(a)')sgtin
do i = 1,6
    read(11,'(a)')ewfout(i)    ! E_ij in cpt_ker.py,
    read(11,'(a)')sgtout1(i)   ! sgtijm in cpt_ker.py
    read(11,'(a)')sgtout2(i)   ! sgtijm in cpt_ker.py
    read(11,'(a)')sgtout3(i)   ! sgtijm in cpt_ker.py
end do
read(11,'(a)')isfpth
read(11,'(a)')fdpth
read(11,'(a)')jtpth
read(11,'(a)')kerpth
read(11,*)dt,nt

read(11,*)dx1,dx2,dx3
read(11,*)cmpid
read(11,*)ssc
read(11,*)xgs,ygs,zgs
read(11,*)xgr,ygr,zgr
close(11)

print*,'rank=', rank, ' finish reading input file ',trim(input)
call MPI_BARRIER(MPI_COMM_WORLD,err)

! 1.2. test input paths:

if (rank.eq.0) then
    
    write(rankchar,'(i6.6)')rank
    open( 12, file='out/debug/testinput-'//rankchar, form='formatted')
    
    ! you can write all of this into a file and check with input_file
    write(12,'(1x,a)')xyzgrd
    write(12,'(a)')pxyzgrd
    write(12,'(a)')Ppth
    write(12,'(a)')Spth
    write(12,'(a)')Rpth
    write(12,'(a)')ewfin
    write(12,'(a)')sgtin
    do i = 1,6
        write(12,'(1x,a)')trim( ewfout(i) )
        write(12,'(1x,a)')trim(sgtout1(i))   ! sgtijm in cpt_ker.py
        write(12,'(1x,a)')trim(sgtout2(i))   ! sgtijm in cpt_ker.py
        write(12,'(1x,a)')trim(sgtout3(i))   ! sgtijm in cpt_ker.py
    enddo
    write(12,'(a)')isfpth
    write(12,'(a)')fdpth
    write(12,'(a)')jtpth
    write(12,'(a)')kerpth
    write(12,'(f12.8,i8)')dt,nt
    write(12,'(3f18.5)')dx1,dx2,dx3
    write(12,'(I4)')cmpid
    write(12,'(a)')ssc
    write(12,'(3I6)')xgs,ygs,zgs
    write(12,'(3I6)')xgr,ygr,zgr
    close(12)
    
end if

! compute coefficients for two horizontal component Green Tensors!
! cmpid = 4 Radial; cmpid = 5 Transverse: Z(up), R(from source to receiver),
! T(clockwise from R by 90 degree) form a left-hand system

! 2.1. read stf_im
allocate(stf_im(nt))
open(11,file=trim(sgtin)//'src_history',access='direct',&
    &form='unformatted',recl=bsize*nt)
read(11,rec=1)stf_im
close(11)
maxtmp = 1e-20
itshift = 1
do it = 1,nt
    if (stf_im(it).ge.maxtmp) then
        maxtmp = stf_im(it)
        itshift = it
    endif
enddo

if (rank .eq. 0)then
    write(rankchar,'(i6.6)')rank
    open( 12, file='out/debug/testitshift-'//rankchar, form='formatted')
    write(12,'(I4)')itshift
    close(12)
endif

! 3.1 read isolation filter
print*,'read isolation filter...'
open(11,file=trim(isfpth)//trim(ssc)//'-isf.G',form='formatted')
read(11,*)delta
read(11,*)t0
read(11,*)npts
read(11,*)t1
read(11,*)t2
allocate(tmpzero(4))
do i = 1,4
    read(11,*)tmpzero(i)
enddo

!print*,'rank = ',rank, ' finish reading isf and fd parameters...'
!call MPI_BARRIER(MPI_COMM_WORLD,err)

allocate(isf(int(npts)))
read(11,*)(isf(i),i = 1,int(npts))
close(11)
deallocate( tmpzero )

if (rank .eq. 0)then
    write(rankchar,'(i6.6)')rank
    open( 12, file='out/debug/testisf-'//rankchar, form='formatted')
    write(12,'(f12.8)')t1
    write(12,'(f12.8)')t2
    write(12,'(f12.8)')delta
    write(12,'(f10.2)')npts
    write(12,'(f12.8)')(isf(i),i=1,int(npts))
    close(12)
endif


! 4.1 read frequency-dependent files
open(11,file=trim(fdpth)//trim(ssc)//'-fd.G',form='formatted')
read(11,*)nfreq
allocate(freq(nfreq))
read(11,*)par_sigmai
read(11,*)par_sigmaw
read(11,*)(freq(i),i=1,nfreq)
close(11)

!4.2 test fd
if (rank .eq. 0)then
    write(rankchar,'(i6.6)')rank
    open( 12, file='out/debug/testfd-'//rankchar, form='formatted')
    write(12,'(I4)')nfreq
    write(12,'(2f12.8)')par_sigmai, par_sigmaw
    write(12,'(f12.8)')(freq(i),i=1,nfreq)
    close(12)
endif

print*,'rank = ',rank, ' finish reading isf and fd parameters...'
call MPI_BARRIER(MPI_COMM_WORLD,err)

! 5. compute J(t) and test plot
it1 = int(t1/dt)
it2 = int(t2/dt)

sigma_w = sqrt(par_sigmaw/(t2-t1)) !??? what is the meaning of par_sigmaw?
sigma_i = 2*pi*freq(1)/par_sigmai  !??? what is the meaning of par_sigmai?
if(rank==0)then
    if (nfreq==1)then
        print*,'compute broadband kernels...'
    endif
endif

allocate( riDt(int(npts)) )
allocate( rDt(nfreq,int(npts)), iDt(nfreq,int(npts)) )
do ii = 1,nfreq
    omega_i = freq(ii)*2.0*pi
    call FiWKernel(riDt,isf,delta,sigma_w,omega_i,sigma_i,1)
    iDt(ii,:) = riDt
    call FiWKernel(riDt,isf,delta,sigma_w,omega_i,sigma_i,0)
    rDt(ii,:) = riDt
enddo
if (rank.eq.0)then
    open(11,file=trim(jtpth)//'rDt.dat',form='formatted')
    open(12,file=trim(jtpth)//'iDt.dat',form='formatted')
    ! store t1, t2, and frequencies in rDt file for further usage
    write(11,'(f12.8)')t1
    write(11,'(f12.8)')t2
    do ii = 1,nfreq
        write(11,'(f12.8)')freq(i)
    enddo
    
    do ifreq = 1,nfreq
        write(11,'(E20.8)')(rDt(ifreq,ii),ii = 1,int(npts))
        write(12,'(E20.8)')(iDt(ifreq,ii),ii = 1,int(npts))
    enddo
    close(11)
    close(12)
endif

print*,'rank = ',rank, ' finish constructing J(t)...'
call MPI_BARRIER(MPI_COMM_WORLD,err)

! read global grid and cell structure information
open(11,file=xyzgrd,form='formatted')
read(11,*)nnx,nny,nnz
read(11,*)ncx,ncy,ncz
read(11,*)npx,npy,npz
read(11,*)nngrd
read(11,*)ncgrd
close(11)

if (rank .eq. 0)then
    write(rankchar,'(i6.6)')rank
    open( 12, file='out/debug/testnnp-'//rankchar, form='formatted')
    write(12,'(3I4)')nnx,nny,nnz
    write(12,'(3I4)')ncx,ncy,ncz
    write(12,'(3I4)')npx,npy,npz
    write(12,'(I10)')nngrd
    write(12,'(I10)')ncgrd
    close(12)
endif
nn(1) = nnx
nn(2) = nny
nn(3) = nnz
np3(1) = npx
np3(2) = npy
np3(3) = npz
nl = (nn-1)/np3+1

! 6. parallel compute kernels
! 6.1 construct an ID for an chunk (process) of saved SGT, EWF, and media
allocate( pidmap(0:npz-1,0:npy-1,0:npx-1) )
do ipz = 0,npz-1
    do ipy = 0,npy-1
        do ipx = 0,npx-1
            pidmap(ipz,ipy,ipx) = ipx + npx * ( ipy + npy * ipz )
        enddo
    enddo
enddo

if (rank .eq. 0)then
    write(rankchar,'(i6.6)')rank
    open( 12, file='out/debug/testpid-'//rankchar, form='formatted')
    write(12,'(3I4)')nn(1),nn(2),nn(3)
    write(12,'(3I4)')np3(1),np3(2),np3(3)
    write(12,'(I10)')(((pidmap(ipz,ipy,ipx),ipx=0,npx-1), &
                                            & ipy=0,npy-1), &
                                            & ipz=0,npz-1)
    close(12)
endif


print*,'rank= ',rank,' finish constructing id for processors'
call MPI_BARRIER(MPI_COMM_WORLD,err)

allocate( fpoint1(nfreq),fpoint2(nfreq), fpoint3(nfreq), fpoint4(nfreq) )
do i = 1,nfreq
    ! store one single file for kernel at one frequency!
    write( freqc, '(i1.1)' )i
    call MPI_FILE_OPEN(MPI_COMM_WORLD, 'out/viz/'//'kernel-'//trim(freqc)//'.AP', &
                   MPI_MODE_WRONLY + MPI_MODE_CREATE,       &
                   MPI_INFO_NULL, fpoint1(i), err )
    call MPI_FILE_OPEN(MPI_COMM_WORLD, 'out/viz/'//'kernel-'//trim(freqc)//'.AQ', &
                   MPI_MODE_WRONLY + MPI_MODE_CREATE,       &
                   MPI_INFO_NULL, fpoint2(i), err )
    call MPI_FILE_OPEN(MPI_COMM_WORLD, 'out/viz/'//'kernel-'//trim(freqc)//'.BP', &
                   MPI_MODE_WRONLY + MPI_MODE_CREATE,       &
                   MPI_INFO_NULL, fpoint3(i), err )
    call MPI_FILE_OPEN(MPI_COMM_WORLD, 'out/viz/'//'kernel-'//trim(freqc)//'.BQ', &
                   MPI_MODE_WRONLY + MPI_MODE_CREATE,       &
                   MPI_INFO_NULL, fpoint4(i), err )
enddo

call MPI_TYPE_SIZE( MPI_REAL, r_size, err )

! 5.2 highest loop through processes
do ipz = 0,npz-1
    do ipy = 0,npy-1
        do ipx = 0,npx-1

            ! highest if condition
            if ( rank .eq. pidmap(ipz,ipy,ipx) ) then

                !write(procid,'(i3.3,i3.3,i3.3)')ipx,ipy,ipz   ! check
                
                write( procid, '(i6.6)') pidmap(ipz,ipy,ipx)
                print*,'rank= ',rank,' is now working on ', trim(procid)
                
                write( pxyzid, '(i3.3,i3.3,i3.3)') ipx,ipy,ipz
                
                ! read in local grid information(in chunk or process)
                ! this is for media information reading
                pxyzgrd = trim(pxyzgrd)//'-'//trim(procid)
                open(11,file=pxyzgrd,form='formatted')
                read(11,*)nlgrd  ! local grid point number in each chunk
                print*,'rank= ',rank,' nlgrd= ',nlgrd
                read(11,*)nxt,nyt,nzt
                read(11,*)offset  ! location of file point for each process
                ! read disp for each process see pid_con.f90 for more detail
                close(11)

                ! Vp(ix,iy,iz), ewf(it,iz,iy,ix), ker(iz,iy,ix) or (1:nlgrd)
                ! construct file names with chunk id
                Ppth = trim(Ppth)//'-'//trim(procid)
                Spth = trim(Spth)//'-'//trim(procid)
                Rpth = trim(Rpth)//'-'//trim(procid)

                ! read block by block in each processor and then compute kernels
                ! block by block, too ( how )
                allocate(Vp(nlgrd),Vs(nlgrd),Rho(nlgrd))
                open(11,file=Ppth,form='unformatted',access='direct', &
                     recl = bsize*nlgrd )
                open(12,file=Spth,form='unformatted',access='direct', &
                     recl = bsize*nlgrd )
                open(13,file=Rpth,form='unformatted',access='direct', &
                     recl = bsize*nlgrd )
                
                read(11,rec=1)Vp
                read(12,rec=1)Vs
                read(13,rec=1)Rho
                
                close(11)
                close(12)
                close(13)
                      
                print*,'rank= ',rank,' finish reading media file of processor ', trim(procid)
                call MPI_BARRIER(MPI_COMM_WORLD,err)
                
                ! read in ewf(earthquake-wave-field) and sgt(strain green tensor)
                ! In fortran, array is saved in column 
                allocate( e_ij(nlgrd,nt,6) )   ! when allocate, you already
                                               ! inquire to the memory
                inquire(iolength=ehsize)e_ij(:,:,1)
                
                do ii = 1,6
                    ewftmp = trim(ewfout(ii))//'-'//trim(procid)
                    open(unit=11,file=trim(ewftmp), form='unformatted', access='direct',&
                         recl = ehsize )
                    read(11,rec=1)e_ij(:,:,ii)   ! read in once
                    close(11)
                enddo
                
                print*,'rank= ',rank,' finish reading ewf file of processor ', trim(procid)
                call MPI_BARRIER(MPI_COMM_WORLD,err)
                
                ! update by geoff
                allocate(h_ijm(nlgrd,nt,6))
                inquire(iolength=ehsize)h_ijm(:,:,1)

                if (cmpid.eq.1)then
                    
                    do ii = 1,6
                        sgttmp = trim(sgtout1(ii))//'-'//trim(procid)
                        open(unit=11,file=trim(sgttmp), form='unformatted', access='direct',&
                             recl = ehsize )
                        read(11,rec=1)h_ijm(1:nlgrd,1:nt,ii)
                        close(11)
                    enddo

                else if (cmpid.eq.2)then 
                    do ii = 1,6
                        sgttmp = trim(sgtout2(ii))//'-'//trim(procid)
                        open(unit=11,file=trim(sgttmp), form='unformatted', access='direct',&
                             recl = ehsize )
                        read(11,rec=1)h_ijm(1:nlgrd,1:nt,ii)
                        close(11)
                    enddo
                
                else if (cmpid.eq.3)then
                    do ii = 1,6
                        sgttmp = trim(sgtout3(ii))//'-'//trim(procid)
                        open(unit=11,file=trim(sgttmp), form='unformatted', access='direct',&
                             recl = ehsize )
                        read(11,rec=1)h_ijm(1:nlgrd,1:nt,ii)
                        close(11)
                    enddo
                   
                else
                    print*, 'use correct component id...'
                    
                endif
                
                print*,'rank= ',rank,' finish reading sgt file of processor ', trim(procid)
                call MPI_BARRIER(MPI_COMM_WORLD,err)
                
                ! compute kernels
                allocate(kap(nlgrd,nfreq))
                allocate(kaq(nlgrd,nfreq))
                allocate(kbp(nlgrd,nfreq))
                allocate(kbq(nlgrd,nfreq))
                
                buf_size = nlgrd    ! problem: bufsize is different from 
                allocate(ker_buf(buf_size))
                
                allocate(b(nt),tmp1(nt),tmp2(nt))
                allocate(tmpap(it2-it1+1),tmpaq(it2-it1+1)) 
                allocate(tmpbp(it2-it1+1),tmpbq(it2-it1+1))
                
                it_1 = it1 + itshift
                it_2 = it2 + itshift

                do i = 1,nlgrd
                    ! loop through local grid points in one chunk or process
                    ! a = h_ijm(1,:,i)+h_ijm(2,:,i)+h_ijm(3,:,i)
                    tmp1 = h_ijm(i,:,1)+h_ijm(i,:,2)+h_ijm(i,:,3)
                    b = e_ij(i,:,1)+e_ij(i,:,2)+e_ij(i,:,3)
                    
                    call convlv_t( tmp1, b )
                    
                    call convlv_t(h_ijm(i,:,1),e_ij(i,:,1))
                    call convlv_t(h_ijm(i,:,2),e_ij(i,:,2))
                    call convlv_t(h_ijm(i,:,3),e_ij(i,:,3))
                    call convlv_t(h_ijm(i,:,4),e_ij(i,:,4))
                    call convlv_t(h_ijm(i,:,5),e_ij(i,:,5))
                    call convlv_t(h_ijm(i,:,6),e_ij(i,:,6))
                    
                    ! Po's beta kernels ( not right after talk with Po )
                    !tmp2 = 2*(h_ijm(i,:,1)+h_ijm(i,:,2)+h_ijm(i,:,3)) + &
                    !         h_ijm(i,:,4)+h_ijm(i,:,5)+h_ijm(i,:,6)
                    
                    tmp2 = 2*(h_ijm(i,:,4)+h_ijm(i,:,5)+h_ijm(i,:,6)) + &
                             (h_ijm(i,:,1)+h_ijm(i,:,2)+h_ijm(i,:,3))
                    
                    do ifreq=1,nfreq
                        tmpap = -2*Vp(i)*Rho(i) * &
                                tmp1(it_1:it_2) *&
                                iDt(ifreq,it1:it2)
                        tmpaq = -2*Vp(i)*Rho(i) * &
                                tmp1(it_1:it_2) *&
                                rDt(ifreq,it1:it2)
                        kap(i,ifreq) = sum(tmpap)*dt
                        kaq(i,ifreq) = sum(tmpaq)*dt
                        
                        ! check your formula for beta kernel
                        
                        ! Po's beta kernel
                        !tmpbp = -2*Vs(i)*Rho(i) * &
                        !        (tmp2(it_1:it_2)-tmp1(it_1:it_2)) * &
                        !        iDt(ifreq,it1:it2)
                        !tmpbq = -2*Vs(i)*Rho(i) * &
                        !        (tmp2(it_1:it_2)-tmp1(it_1:it_2)) * &
                        !        rDt(ifreq,it1:it2)
                         
                        ! Feng's beta kernel         
                        tmpbp = -2.0*Vs(i)*Rho(i) * &
                                2.0*(tmp2(it_1:it_2)-tmp1(it_1:it_2)) * &
                                iDt(ifreq,it1:it2)
                        tmpbq = -2.0*Vs(i)*Rho(i) * &
                                2.0*(tmp2(it_1:it_2)-tmp1(it_1:it_2)) * &
                                rDt(ifreq,it1:it2)
                                
                        kbp(i,ifreq) = sum(tmpbp)*dt
                        kbq(i,ifreq) = sum(tmpbq)*dt
                    enddo

                enddo
                
                deallocate(tmp1,b,tmp2,tmpap,tmpaq,tmpbp,tmpbq)
                deallocate(e_ij,h_ijm,Vp,Vs,Rho)
                
                print*,'rank= ',rank,' end convolution'
                
                ! write in file in formatted ASCII files
                !open(11,file=trim(kerpth)//'ker'//pxyzid//'.AP',form='formatted')
                !open(12,file=trim(kerpth)//'ker'//pxyzid//'.AQ',form='formatted')
                !open(13,file=trim(kerpth)//'ker'//pxyzid//'.BP',form='formatted')
                !open(14,file=trim(kerpth)//'ker'//pxyzid//'.BQ',form='formatted')
                !do ifreq = 1,nfreq
                !    write(11,'(E20.8)')(kap(i,ifreq),i = 1,nlgrd)
                !    write(12,'(E20.8)')(kaq(i,ifreq),i = 1,nlgrd)
                !    write(13,'(E20.8)')(kbp(i,ifreq),i = 1,nlgrd)
                !    write(14,'(E20.8)')(kbq(i,ifreq),i = 1,nlgrd)
                !enddo
                
                ! write into file in unformatted binary files
                open(11,file=trim(kerpth)//'ker'//trim(pxyzid)//'.AP',form='unformatted',&
                     access='direct',status='new',recl=bsize*nlgrd)
                open(12,file=trim(kerpth)//'ker'//trim(pxyzid)//'.AQ',form='unformatted',&
                     access='direct',status='new',recl=bsize*nlgrd)
                open(13,file=trim(kerpth)//'ker'//trim(pxyzid)//'.BP',form='unformatted',&
                     access='direct',status='new',recl=bsize*nlgrd)
                open(14,file=trim(kerpth)//'ker'//trim(pxyzid)//'.BQ',form='unformatted',&
                     access='direct',status='new',recl=bsize*nlgrd)
                do ifreq = 1,nfreq
                    write(11,rec=ifreq)(kap(i,ifreq),i=1,nlgrd)
                    write(12,rec=ifreq)(kaq(i,ifreq),i=1,nlgrd)
                    write(13,rec=ifreq)(kbp(i,ifreq),i=1,nlgrd)
                    write(14,rec=ifreq)(kbq(i,ifreq),i=1,nlgrd)
                enddo
                
                close(11)
                close(12)
                close(13)
                close(14)
                
                
                ! collect kernel files 
                ! notes: the bufsize for each rank is different, so disp is hard
                ! to compute according to rank !

                disp = offset  * r_size
                do ifreq = 1,nfreq
                
                    do i = 1,nlgrd
                        ker_buf(i) = kap(i,ifreq)
                    enddo
                    CALL MPI_FILE_SEEK( fpoint1(ifreq), disp, MPI_SEEK_SET, err)
                    CALL MPI_FILE_WRITE( fpoint1(ifreq), ker_buf, buf_size, &
                                        MPI_REAL, stats,err )
                    do i = 1,nlgrd
                        ker_buf(i) = kaq(i,ifreq)
                    enddo
                    CALL MPI_FILE_SEEK( fpoint2(ifreq), disp, MPI_SEEK_SET, err)
                    CALL MPI_FILE_WRITE( fpoint2(ifreq), ker_buf, buf_size, &
                                        MPI_REAL, stats, err )
                    do i = 1,nlgrd
                        ker_buf(i) = kbp(i,ifreq)
                    enddo
                    CALL MPI_FILE_SEEK( fpoint3(ifreq), disp, MPI_SEEK_SET, err)
                    CALL MPI_FILE_WRITE( fpoint3(ifreq), ker_buf, buf_size, &
                                        MPI_REAL, stats, err )
                    do i = 1,nlgrd
                        ker_buf(i) = kbq(i,ifreq)
                    enddo
                    CALL MPI_FILE_SEEK( fpoint4(ifreq), disp, MPI_SEEK_SET, err)
                    CALL MPI_FILE_WRITE( fpoint4(ifreq), ker_buf, buf_size, &
                                        MPI_REAL, stats, err )
                
                enddo
                
                deallocate(kap,kaq,kbp,kbq)

            endif
        enddo
    enddo
enddo


deallocate(stf_im,isf,freq,riDt,rDt,iDt,pidmap)

do i = 1,nfreq

    CALL MPI_FILE_CLOSE( fpoint1(i), err )
    CALL MPI_FILE_CLOSE( fpoint2(i), err )
    CALL MPI_FILE_CLOSE( fpoint3(i), err )
    CALL MPI_FILE_CLOSE( fpoint4(i), err )

enddo

call MPI_BARRIER(MPI_COMM_WORLD,err)
if (rank.eq.0)print*,'Kernel computing finished...'
call MPI_FINALIZE(err)

end program cpt_ker
