! read model parameters
module parameters
use globals
use collective
implicit none
contains

! not sure how to allocate character arrays on the heap,
! so call sub-function and allocate on the stack.
subroutine read_parameters
integer :: n
if (master) inquire (file='parameters.txt', size=n)
call ibroadcast(n)
call read_parameters1(n)
end subroutine

! read parameters sub-function
subroutine read_parameters1(n)
use field_io_mod
use utilities
integer, intent(in) :: n
integer :: i, j
character(n) :: str

! read with master process
if (master) then
    print *, clock(), 'Read parameters'
    open (1, file='parameters.txt', recl=n, form='unformatted', access='direct', &
        status='old')
    read (1, rec=1) str
    close (1)
end if
call cbroadcast(str)

! read parameters
read (str, *) &
    affine, bc1, bc2, debug, delta, faultnormal, faultopening, gam1, gam2, &
    gridnoise, hourglass, i1pml, i2pml, ihypo, itio, itstats, mpin, mpout, &
    n1expand, n2expand, npml, nproc3, nsource, nthread, oplevel, ppml, rcrit, &
    rexpand, rho1, rho2, shape_, slipvector, source, svtol, tm0, trelax, vdamp, &
    vp1, vp2, vpml, vrup, vs1, vs2, io2

! find start of fieldio and change file delimeter
i = scan(str, '>')
str = str(i:)
do
    i = scan(str, '/')
    if (i == 0) exit
    str(i:i) = '\'
end do

! field i/o
allocate (io_list(io2))
do j = 1, io2
    io => io_list(j)
    i = scan(str, new_line('a')) + 1
    str = str(i:)
    io%ib = -1
    read (str, *) io%field, io%reg, io%ii, io%nb, io%x1, io%x2, &
        io%val, io%tau, io%op, io%fname
    do
        i = scan(io%fname, '\')
        if (i == 0) exit
        io%fname(i:i) = '/'
    end do
end do

end subroutine

end module

