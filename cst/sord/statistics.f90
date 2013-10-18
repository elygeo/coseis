! collect statistics and timing
module statistics
integer, dimension(3) :: &
    amaxloc, vmaxloc, umaxloc, wmaxloc
real :: &
    amax, vmax, umax, wmax, &
    samax, svmax, sumax, slmax, &
    tsmax, tnmin, tnmax, tarrmax, &
    efric, estrain, moment
contains

! write statistics
subroutine stats
use globals
use collective
use utilities
logical, save :: init = .true.
integer, save :: fh(20), j = 0
integer, save, allocatable :: prof(:,:)
real, save, allocatable :: maxl(:,:), suml(:,:), maxg(:,:), sumg(:,:)
integer :: m, o, i
real :: val

! init 
if (sync) call barrier
timers(3) = clock()

! allocate buffers
if (init) then
    init = .false.
    allocate(prof(4,itio))
    if (faultnormal /= 'no') then
        allocate (maxl(12,itio), maxg(12,itio), suml(3,itio), sumg(3,itio))
        suml = 0.0
        sumg = 0.0
    else
        allocate (maxl(4,itio), maxg(4,itio))
    end if
    maxl = 0.0
    maxg = 0.0
    fh = -1
    if (mpout /= 0) fh = file_null
end if

! buffer stats
if (modulo(it, itstats) == 0) then
    j = j + 1
    maxl(1,j) = amax
    maxl(2,j) = vmax
    maxl(3,j) = umax
    maxl(4,j) = wmax
    val = maxval(maxl)
    if (val /= val .or. val > huge(val)) then
        write (0,*) 'NaN/Inf!'
        write (0,*) 'amax:', amaxloc + nnoff, amax
        write (0,*) 'vmax:', vmaxloc + nnoff, vmax
        write (0,*) 'umax:', umaxloc + nnoff, umax
        write (0,*) 'wmax:', wmaxloc + nnoff, wmax
        stop
    end if
    if (faultnormal /= 'no') then
        maxl(5,j) = samax
        maxl(6,j) = svmax
        maxl(7,j) = sumax
        maxl(8,j) = slmax
        maxl(9,j) = tsmax
        maxl(10,j) = -tnmin
        maxl(11,j) = tnmax
        maxl(12,j) = tarrmax
        suml(1,j) = efric
        suml(2,j) = estrain
        suml(3,j) = moment
    end if
end if

! write stats
if (j > 0 .and. (modulo(it, itio) == 0 .or. it == nt)) then
    call rreduce2(maxg, maxl, 'max')
    if (faultnormal /= 'no') then
        call rreduce2(sumg, suml, 'sum')
    end if
    if (master) then
        m = nt / itstats
        o = it / itstats - j
        maxg(:4,:j) = sqrt(maxg(:4,:j))
        call rio1(fh(1), maxg(1,:j), 'w', 'stats-amax.bin', m, o, mpout)
        call rio1(fh(2), maxg(2,:j), 'w', 'stats-vmax.bin', m, o, mpout)
        call rio1(fh(3), maxg(3,:j), 'w', 'stats-umax.bin', m, o, mpout)
        call rio1(fh(4), maxg(4,:j), 'w', 'stats-wmax.bin', m, o, mpout)
        if (faultnormal /= 'no') then
            maxg(10,:j) = -maxg(10,:j)
            call rio1(fh(5),  maxg(5,:j),  'w', 'stats-samax.bin',   m, o, mpout)
            call rio1(fh(6),  maxg(6,:j),  'w', 'stats-svmax.bin',   m, o, mpout)
            call rio1(fh(7),  maxg(7,:j),  'w', 'stats-sumax.bin',   m, o, mpout)
            call rio1(fh(8),  maxg(8,:j),  'w', 'stats-slmax.bin',   m, o, mpout)
            call rio1(fh(9),  maxg(9,:j),  'w', 'stats-tsmax.bin',   m, o, mpout)
            call rio1(fh(10), maxg(10,:j), 'w', 'stats-tnmin.bin',   m, o, mpout)
            call rio1(fh(11), maxg(11,:j), 'w', 'stats-tnmax.bin',   m, o, mpout)
            call rio1(fh(12), maxg(12,:j), 'w', 'stats-tarrmax.bin', m, o, mpout)
            call rio1(fh(13), sumg(1,:j),  'w', 'stats-efric.bin',   m, o, mpout)
            call rio1(fh(14), sumg(2,:j),  'w', 'stats-estrain.bin', m, o, mpout)
            call rio1(fh(15), sumg(3,:j),  'w', 'stats-moment.bin',  m, o, mpout)
            do i = 1, j
                if (sumg(3,i) > 0.0) then
                    sumg(3,i) = (log10(sumg(3,i)) - 9.05) / 1.5
                else
                    sumg(3,i) = -999
                end if
            end do
            call rio1(fh(16), sumg(3,:j),'w', 'stats-mw.bin', m, o, mpout)
        end if
    end if
    j = 0
end if

! profile
if (sync) call barrier
if (master) then
    timers(4) = clock()
    timers(3) = timers(4) - timers(3)
    i = modulo(it - 1, itio) + 1
    prof(:,i) = timers
    if (i == itio .or. it == nt) then
        call iio1(fh(17), prof(1,:i), 'w', 'prof-halo.bin',  nt, it-i, mpout)
        call iio1(fh(18), prof(2,:i), 'w', 'prof-io.bin',    nt, it-i, mpout)
        call iio1(fh(19), prof(3,:i), 'w', 'prof-stats.bin', nt, it-i, mpout)
        call iio1(fh(20), prof(4,:i), 'w', 'prof-step.bin',  nt, it-i, mpout)
    end if
end if

end subroutine

end module

