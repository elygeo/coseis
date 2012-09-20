! read model parameters
module parameters
implicit none
contains

subroutine read_parameters
use globals
use field_io_mod
integer :: ios, i

! i/o pointers
allocate (io0)
io => io0
io%next => io0
io%field = 'head'

select case (key(1:1))
case ('=', '+')
    call pappend
    do
        i = scan(str, '/')
        if (i == 0) exit
        str(i:i) = '#'
    end do
    io%ib = -1
    !XXXread (str, *, iostat=ios) io%mode, io%nc
    read (str, *, iostat=ios) io%mode, io%nc, io%pulse, &
        io%tau, io%x1, io%x2, io%nb, io%ii, io%filename, &
        io%val, io%field
    do
        i = scan(io%filename, '#')
        if (i == 0) exit
        io%filename(i:i) = '/'
    end do
case default; ios = 1
end select

end subroutine

end module

