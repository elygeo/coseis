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
if (master) inquire (file='parameters.py', size=n)
call ibroadcast(n)
call read_parameters1(n)
end subroutine

! read parameters sub-function
subroutine read_parameters1(n)
use field_io_mod
use utilities
integer, intent(in) :: n
integer :: ios, i, j
character(256) :: line
character(12) :: key
character(1) :: op
character(n) :: str

! read with master process
if (master) then
    print *, clock(), 'Read parameters'
    open (1, file='parameters.py', recl=n, form='unformatted', access='direct', &
        status='old')
    read (1, rec=1) str
    close (1)
end if
call cbroadcast(str)

! i/o pointers
allocate (io0)
io => io0
io%next => io0
io%field = 'head'

j = -1
doline: do

! find newline
str = str(j+2:)
j = scan(str, new_line('a')) - 1
if (j == -1) exit doline
if (j == 0) cycle doline
line = str(:j)

! strip comments and punctuation
i = scan(line, '#')
if (i > 0) line(i:) = ' '
do
    i = scan(line, "()[]{}'")
    if (i == 0) exit
    line(i:i) = ' '
end do

! read key val pair
if (line == '') cycle doline
read (line, *, iostat=ios) key

! select input key
select case (key)
case ('fieldio', 'itbuff', '')
case ('shape');        read (line, *, iostat=ios) key, op, shape_
case ('delta');        read (line, *, iostat=ios) key, op, delta
case ('tm0');          read (line, *, iostat=ios) key, op, tm0
case ('affine');       read (line, *, iostat=ios) key, op, affine
case ('n1expand');     read (line, *, iostat=ios) key, op, n1expand
case ('n2expand');     read (line, *, iostat=ios) key, op, n2expand
case ('rexpand');      read (line, *, iostat=ios) key, op, rexpand
case ('gridnoise');    read (line, *, iostat=ios) key, op, gridnoise
case ('oplevel');      read (line, *, iostat=ios) key, op, oplevel
case ('rho1');         read (line, *, iostat=ios) key, op, rho1
case ('rho2');         read (line, *, iostat=ios) key, op, rho2
case ('vp1');          read (line, *, iostat=ios) key, op, vp1
case ('vp2');          read (line, *, iostat=ios) key, op, vp2
case ('vs1');          read (line, *, iostat=ios) key, op, vs1
case ('vs2');          read (line, *, iostat=ios) key, op, vs2
case ('gam1');         read (line, *, iostat=ios) key, op, gam1
case ('gam2');         read (line, *, iostat=ios) key, op, gam2
case ('vdamp');        read (line, *, iostat=ios) key, op, vdamp
case ('hourglass');    read (line, *, iostat=ios) key, op, hourglass
case ('bc1');          read (line, *, iostat=ios) key, op, bc1
case ('bc2');          read (line, *, iostat=ios) key, op, bc2
case ('npml');         read (line, *, iostat=ios) key, op, npml
case ('i1pml');        read (line, *, iostat=ios) key, op, i1pml
case ('i2pml');        read (line, *, iostat=ios) key, op, i2pml
case ('ppml');         read (line, *, iostat=ios) key, op, ppml
case ('vpml');         read (line, *, iostat=ios) key, op, vpml
case ('ihypo');        read (line, *, iostat=ios) key, op, ihypo
case ('source');       read (line, *, iostat=ios) key, op, source
case ('pulse');        read (line, *, iostat=ios) key, op, pulse
case ('tau');          read (line, *, iostat=ios) key, op, tau
case ('source1');      read (line, *, iostat=ios) key, op, source1
case ('source2');      read (line, *, iostat=ios) key, op, source2
case ('nsource');      read (line, *, iostat=ios) key, op, nsource
case ('faultnormal');  read (line, *, iostat=ios) key, op, faultnormal
case ('slipvector');   read (line, *, iostat=ios) key, op, slipvector
case ('faultopening'); read (line, *, iostat=ios) key, op, faultopening
case ('vrup');         read (line, *, iostat=ios) key, op, vrup
case ('rcrit');        read (line, *, iostat=ios) key, op, rcrit
case ('trelax');       read (line, *, iostat=ios) key, op, trelax
case ('svtol');        read (line, *, iostat=ios) key, op, svtol
case ('nproc3');       read (line, *, iostat=ios) key, op, nproc3
case ('itstats');      read (line, *, iostat=ios) key, op, itstats
case ('itio');         read (line, *, iostat=ios) key, op, itio
case ('debug');        read (line, *, iostat=ios) key, op, debug
case ('mpin');         read (line, *, iostat=ios) key, op, mpin
case ('mpout');        read (line, *, iostat=ios) key, op, mpout
case default
    select case (key(1:1))
    case ('=', '+')
        call pappend
        do
            i = scan(line, '/')
            if (i == 0) exit
            str(i:i) = '#'
        end do
        io%ib = -1
        read (line, *, iostat=ios) io%mode, io%nc, io%pulse, &
            io%tau, io%x1, io%x2, io%nb, io%ii, io%filename, &
            io%val, io%field
        do
            i = scan(io%filename, '#')
            if (i == 0) exit
            io%filename(i:i) = '/'
        end do
    case default; ios = 1
    end select
end select

! error check
if (ios /= 0) then
    if (master) write (0,*) 'bad input: ', trim(str(:j))
    stop
end if

end do doline

end subroutine

end module

