! field input and output
module field_io_mod
implicit none
integer :: io1 = 1, io2
integer, private :: itdebug = -1, idebug
type t_io
    real :: x1(3), x2(3), val, tau
    integer :: ii(3,4), nb, ib, fh
    real, pointer :: buff(:,:)     ! buffer for storing multiple time steps
    character(32) :: fname         ! file or function nameD on disk for input or output
    character(5) :: field          ! field variable, see fieldnames.yaml
    character(2) :: op             ! '<' read, '>' write, '=' set, '+' add
    character :: reg               ! n: node, c: cell registration
end type t_io
type (t_io), pointer :: io
type (t_io), allocatable, target :: io_list(:)
contains

! field i/o sequence
subroutine field_io(passes, field, f)
use globals
use utilities
use collective
use fortran_io
use boundary_cond
character(*), intent(in) :: passes, field
real, intent(inout) :: f(:,:,:)
character(4) :: pass
character(256) :: filename
integer :: i1(3), i2(3), i3(3), i4(3), di(3), m(4), n(4), o(4), &
    it1, it2, dit, i, j, k, l, ipass, iloop, io1_, io2_
real :: val, xi(3), r

! profiling
if (sync) call barrier
timers(2) = timers(2) - clock()

! pass loop
do ipass = 1, len(passes)
pass = passes(ipass:ipass)

! i/o list loop
io1_ = io1
io2_ = io2
io1 = max(io1, io2_)
io2 = min(io2, io1_)
loop: do iloop = io1_, io2_
io => io_list(iloop)

! time indices
it1 = io%ii(1,4)
it2 = io%ii(2,4)
dit = io%ii(3,4)

! skip forever
if (it > it2) cycle loop
if (io%op(1:1) == '#') cycle loop
io1 = min(io1, iloop)
io2 = max(io2, iloop)

! skip this time
if (it < it1) cycle loop
if (modulo(it - it1, dit) /= 0) cycle loop
if (field /= io%field) cycle loop
if (pass == '<' .and. io%op(2:2) == '>') cycle loop
if (pass == '>' .and. io%op(2:2) /= '>') cycle loop

! spatial indices
if (io%reg == 'n') then
    i3 = i1node
    i4 = i2node
    xi = io%x1 - nnoff
else
    i3 = i1cell
    i4 = i2cell
    xi = io%x1 - 0.5 - nnoff
end if
if (io%op(1:1) == '.') then
    i1 = max(i3, floor(xi))
    i2 = min(i4, floor(xi) + 1)
    di = 1
else
    i1 = io%ii(1,1:3) - nnoff
    i2 = io%ii(2,1:3) - nnoff
    di = io%ii(3,1:3)
    where (i1 < i3) i1 = i1 + ((i3 - i1 - 1) / di + 1) * di
    where (i2 > i4) i2 = i1 +  (i4 - i1)     / di      * di
end if

! non-disk input
if (io%op(2:2) /= '<' .and. io%op(2:2) /= '>') then
    if (any(i2 < i1)) then
        io%op = '#'
        cycle loop
    end if
    val = io%val * time_function(io%fname, tm, dt, io%tau)
    select case (io%op)
    case ('.')
        do l = i1(3), i2(3)
        do k = i1(2), i3(2)
        do j = i1(1), i3(1)
            r = (1.0-abs(xi(1)-j)) * (1.0-abs(xi(2)-k)) * (1.0-abs(xi(3)-l))
            f(j,k,l) = f(j,k,l) + val * r
        end do
        end do
        end do
    case ('=')
        do l = i1(3), i2(3), di(3)
        do k = i1(2), i2(2), di(2)
        do j = i1(1), i2(1), di(1)
            f(j,k,l) = val
        end do
        end do
        end do
    case ('+')
        do l = i1(3), i2(3), di(3)
        do k = i1(2), i2(2), di(2)
        do j = i1(1), i2(1), di(1)
            f(j,k,l) = f(j,k,l) + val
        end do
        end do
        end do
    case ('*')
        do l = i1(3), i2(3), di(3)
        do k = i1(2), i2(2), di(2)
        do j = i1(1), i2(1), di(1)
            f(j,k,l) = f(j,k,l) * val
        end do
        end do
        end do
    case ('=~')
        call random_number(s1)
        call scalar_swap_halo(s1, nhalo)
        do l = i1(3), i2(3), di(3)
        do k = i1(2), i2(2), di(2)
        do j = i1(1), i2(1), di(1)
            f(j,k,l) = val * s1(j,k,l)
        end do
        end do
        end do
    case ('+~')
        call random_number(s1)
        call scalar_swap_halo(s1, nhalo)
        do l = i1(3), i2(3), di(3)
        do k = i1(2), i2(2), di(2)
        do j = i1(1), i2(1), di(1)
            f(j,k,l) = f(j,k,l) + val * s1(j,k,l)
        end do
        end do
        end do
    case ('*~')
        call random_number(s1)
        call scalar_swap_halo(s1, nhalo)
        do l = i1(3), i2(3), di(3)
        do k = i1(2), i2(2), di(2)
        do j = i1(1), i2(1), di(1)
            f(j,k,l) = f(j,k,l) * val * s1(j,k,l)
        end do
        end do
        end do
    case ('=@', '+@', '*@')
        if (io%reg == 'n') then
            call set_cube(f, w1, i1, i2, di, io%x1, io%x2, val, io%op)
        else
            call set_cube(f, w2, i1, i2, di, io%x1, io%x2, val, io%op)
        end if
    case default
        write (0,*) "bad i/o mode '", trim(io%op)
        stop
    end select
    if (io%reg == 'n') call scalar_bc(f, bc1, bc2, i1bc, i2bc)
    if (io%reg == 'c') call scalar_bc(f, bc1, bc2, i1bc, i2bc - 1)
    cycle loop
end if

! spatial indices for disk i/o
if (io%op(1:1) == '.') then
    m = 1
    n = 1
    o = 0
else
    i1 = io%ii(1,1:3) - nnoff
    i2 = io%ii(2,1:3) - nnoff
    di = io%ii(3,1:3)
    i3 = i1
    i4 = i2
    where (i1 < i1core) i1 = i1 + ((i1core - i1 - 1) / di + 1) * di
    where (i2 > i2core) i2 = i1 +  (i2core - i1)     / di      * di
    m(1:3) = (i4 - i3) / di + 1
    n(1:3) = (i2 - i1) / di + 1
    o(1:3) = (i1 - i3) / di
    n = max(n, 0)
end if

! array dimensionality
do i = 1, 3
    if (size(f, i) == 1) then
        if (n(i) < 1) then
            io%op = '#'
            cycle loop
        end if
        i1(i) = 1
        i2(i) = 1
        m(i) = 1
        n(i) = 1
        o(i) = 0
    end if
end do

! disk input
if (io%op(2:2) == '<') then

    ! half-dimension fill
    if (io%op /= '.<') then
        do i = 1, 3
            if (m(i) == 1) then
                i1(i) = 1
                i2(i) = 1
                n(i) = 1
                o(i) = 0
            end if
        end do
    end if

    ! allocate buffer
    if (io%ib < 0) then
        allocate (io%buff(n(1)*n(2)*n(3),io%nb))
        io%ib = io%nb
        io%fh = fio_file_null
        if (mpin /= 0) io%fh = file_null
    end if

    ! read into buffer
    if (io%ib == io%nb) then
        n(4) = min(io%nb, (it2 - it) / dit + 1)
        m(4) = (it2 - it1) / dit + 1
        o(4) = (it  - it1) / dit
        filename = io%fname
        if (any(n(1:3) /= m(1:3)) .and. mpin == 0) &
            write (filename, '(2a,i6.6)') trim(filename), '-', ip
        call rio2(io%fh, io%buff(:,:n(4)), 'r', trim(filename), m, n, o, mpin)
        io%ib = 0
        if (any(n < 1)) then
            deallocate (io%buff)
            io%op = '#'
            cycle loop
        end if
        if ( any(io%buff(:,:n(4)) /= io%buff(:,:n(4))) .or. &
            maxval(io%buff(:,:n(4))) > huge(val) ) then
            write (0,*) 'NaN/Inf in ', trim(io%fname)
            stop
        end if
    end if

    ! buffer counter
    io%ib = io%ib + 1

    if (io%op == '.<') then

        ! sub-cell interpolation
        do l = i1(3), i2(3)
        do k = i1(2), i2(2)
        do j = i1(1), i2(1)
            r = (1.0-abs(xi(1)-j)) * (1.0-abs(xi(2)-k)) * (1.0-abs(xi(3)-l))
            f(j,k,l) = f(j,k,l) + r * io%buff(i,io%ib)
        end do
        end do
        end do

    else

        ! copy buffer to temp array
        i = 0
        do l = i1(3), i2(3), di(3)
        do k = i1(2), i2(2), di(2)
        do j = i1(1), i2(1), di(1)
            i = i + 1
            s1(j,k,l) = io%buff(i,io%ib)
        end do
        end do
        end do
        call scalar_swap_halo(s1, nhalo)

        ! interpolate
        if (any(di > 1)) then
            if (any(di > nhalo .and. nproc3 > 1)) stop 'di too large for nhalo'
            i3 = io%ii(1,1:3) - nnoff
            i4 = io%ii(2,1:3) - nnoff
            call interpolate(s1, i3, i4, di)
        end if

        ! half-dimension fill
        if (m(1) == 1) then
            i2(1) = size(f, 1)
            do i = 2, i2(1)
                s1(i,:,:) = s1(1,:,:)
            end do
        end if
        if (m(2) == 1) then
            i2(2) = size(f, 2)
            do i = 2, i2(2)
                s1(:,i,:) = s1(:,1,:)
            end do
        end if
        if (m(3) == 1) then
            i2(3) = size(f, 3)
            do i = 2, i2(3)
                s1(:,:,i) = s1(:,:,1)
            end do
        end if

        ! array operation
        if (io%op == '=<') then
            do l = i1(3), i2(3)
            do k = i1(2), i2(2)
            do j = i1(1), i2(1)
                f(j,k,l) = s1(j,k,l)
            end do
            end do
            end do
        elseif (io%op == '+<') then
            do l = i1(3), i2(3)
            do k = i1(2), i2(2)
            do j = i1(1), i2(1)
                f(j,k,l) = f(j,k,l) + s1(j,k,l)
            end do
            end do
            end do
        elseif (io%op == '*<') then
            do l = i1(3), i2(3)
            do k = i1(2), i2(2)
            do j = i1(1), i2(1)
                f(j,k,l) = f(j,k,l) * s1(j,k,l)
            end do
            end do
            end do
        else
            stop 'bad i/o op'
        end if
    end if

    ! boundary conditions
    if (io%reg == 'n') call scalar_bc(f, bc1, bc2, i1bc, i2bc)
    if (io%reg == 'c') call scalar_bc(f, bc1, bc2, i1bc, i2bc - 1)
    if (it == it2) then
        deallocate (io%buff)
        io%op = '#'
    end if

    cycle loop

end if

! disk output
if (io%op(2:2) == '>') then

    ! sub-cell interpolation, only 1 proc
    if (io%op == '.>') then
        if (any(i2 < i1core .or. i2 > i2core)) then
            io%op = '#'
            cycle loop
        end if
    end if

    ! allocate buffer
    if (io%ib < 0) then
        allocate (io%buff(n(1)*n(2)*n(3),io%nb))
        io%ib = 0
        io%fh = fio_file_null
        if (mpout /= 0) io%fh = file_null
    end if

    ! compute magnitudes
    if (modulo(it, itstats) /= 0) then
        select case (io%field)
        case ('vm2'); call vector_norm(f, vv, i1, i2, di)
        case ('um2'); call vector_norm(f, uu, i1, i2, di)
        case ('wm2'); call tensor_norm(f, w1, w2, i1, i2, di)
        case ('am2'); call vector_norm(f, w1, i1, i2, di)
        end select
    end if

    ! copy to buffer
    io%ib = io%ib + 1
    if (io%op == '.>') then
        io%buff(1,io%ib) = 0.0
        do l = i1(3), i2(3)
        do k = i1(2), i2(2)
        do j = i1(1), i2(1)
            r = (1.0-abs(xi(1)-j)) * (1.0-abs(xi(2)-k)) * (1.0-abs(xi(3)-l))
            io%buff(1,io%ib) = io%buff(1,io%ib) + f(j,k,l) * r
        end do
        end do
        end do
    elseif (io%op == '=>') then
        i = 0
        do l = i1(3), i2(3), di(3)
        do k = i1(2), i2(2), di(2)
        do j = i1(1), i2(1), di(1)
            i = i + 1
            io%buff(i,io%ib) = f(j,k,l)
        end do
        end do
        end do
    else
        stop 'bad i/o op'
    end if

    ! write buffer to file
    if (io%ib == io%nb .or. it == it2 .or. modulo(it, itio) == 0) then
        n(4) = io%ib
        m(4) = (it2 - it1) / dit + 1
        o(4) = (it  - it1) / dit + 1 - n(4)
        filename = io%fname
        if (any(n(1:3) /= m(1:3)) .and. mpout == 0) &
            write (filename, '(2a,i6.6)') trim(filename), '-', ip
        call rio2(io%fh, io%buff(:,:n(4)), 'w', trim(filename), m, n, o, mpout)
        io%ib = 0
        if (it == it2 .or. any(n < 1)) then
            deallocate (io%buff)
            io%op = '#'
        end if
    end if

    cycle loop

end if

stop 'bad i/o op'

end do loop
end do

! debug output
i = scan(passes, '>')
if (i > 0 .and. debug > 3 .and. it <= 8) then
    if (itdebug /= it) then
        itdebug = it
        idebug = 0
    end if
    idebug = idebug + 1
    write (filename, "(a,3(i4.4,'-'),a)") 'debug/f', it, idebug, ip, field
    open (1, file=filename, status='replace')
    do l = 1, size(f, 3)
        write (1, '(i4,1x,i4,1x,a)') it, l, field
        do k = 1, size(f, 2)
            write (1, '(16g15.7)') f(:,k,l)
        end do
    end do
    close (1)
end if

! profiling
if (sync) call barrier
timers(2) = timers(2) + clock()

end subroutine

!------------------------------------------------------------------------------!

subroutine set_cube(f, x, i1, i2, di, x1, x2, r, op)
real, intent(inout) :: f(:,:,:)
real, intent(in) :: x(:,:,:,:), x1(3), x2(3), r
integer, intent(in) :: i1(3), i2(3), di(3)
character(*), intent(in) :: op
integer :: n(3), o(3), j, k, l
n = (/size(f,1), size(f,2), size(f,3)/)
o = 0
where (n == 1) o = 1 - i1
select case (op(1:1))
case ('=')
    do l = i1(3), i2(3), di(3)
    do k = i1(2), i2(2), di(2)
    do j = i1(1), i2(1), di(1)
    if ( x(j,k,l,1) >= x1(1) .and. x(j,k,l,1) <= x2(1) .and. &
         x(j,k,l,2) >= x1(2) .and. x(j,k,l,2) <= x2(2) .and. &
         x(j,k,l,3) >= x1(3) .and. x(j,k,l,3) <= x2(3) ) &
         f(j+o(1),k+o(2),l+o(3)) = r
    end do
    end do
    end do
case ('+')
    do l = i1(3), i2(3), di(3)
    do k = i1(2), i2(2), di(2)
    do j = i1(1), i2(1), di(1)
    if ( x(j,k,l,1) >= x1(1) .and. x(j,k,l,1) <= x2(1) .and. &
         x(j,k,l,2) >= x1(2) .and. x(j,k,l,2) <= x2(2) .and. &
         x(j,k,l,3) >= x1(3) .and. x(j,k,l,3) <= x2(3) ) &
         f(j+o(1),k+o(2),l+o(3)) = f(j+o(1),k+o(2),l+o(3)) + r
    end do
    end do
    end do
case ('*')
    do l = i1(3), i2(3), di(3)
    do k = i1(2), i2(2), di(2)
    do j = i1(1), i2(1), di(1)
    if ( x(j,k,l,1) >= x1(1) .and. x(j,k,l,1) <= x2(1) .and. &
         x(j,k,l,2) >= x1(2) .and. x(j,k,l,2) <= x2(2) .and. &
         x(j,k,l,3) >= x1(3) .and. x(j,k,l,3) <= x2(3) ) &
         f(j+o(1),k+o(2),l+o(3)) = f(j+o(1),k+o(2),l+o(3)) * r
    end do
    end do
    end do
case default; stop 'error in cube'
end select
end subroutine

end module

