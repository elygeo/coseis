! collect statistics
module m_stats
real :: &
    amax, vmax, umax, wmax, &
    samax, svmax, sumax, slmax, &
    tsmax, tnmin, tnmax, tarrmax, &
    efric, estrain, moment
contains

! write statistics
subroutine stats
use m_globals
use m_collective
use m_util
logical, save :: init = .true., dofault = .false.
integer, save :: fh(16), j = 0
integer :: m, o, i
real :: rr
real, save, allocatable, dimension(:,:) :: &
    vstats, fstats, estats, gvstats, gfstats, gestats

! start timer
if ( verb ) write( 0, * ) 'Statistics'

! allocate buffers
if ( init ) then
    init = .false.
    if ( faultnormal /= 0 ) then
        i = abs( faultnormal )
        if ( ip3(i) == ip3root(i) ) dofault = .true.
    end if
    allocate( vstats(4,itio), fstats(8,itio), estats(3,itio), &
        gvstats(4,itio), gfstats(8,itio), gestats(3,itio) )
    vstats = 0.0
    fstats = 0.0
    estats = 0.0
    gvstats = 0.0
    gfstats = 0.0
    gestats = 0.0
    fh = -1
    if ( mpout /= 0 ) fh = file_null
end if

! buffer stats
if ( modulo( it, itstats ) == 0 ) then
    j = j + 1
    vstats(1,j) = amax
    vstats(2,j) = vmax
    vstats(3,j) = umax
    vstats(4,j) = wmax
    rr = maxval( vstats )
    if ( rr /= rr .or. rr > huge( rr ) ) stop 'NaN/Inf!'
    if ( dofault ) then
        fstats(1,j) = samax
        fstats(2,j) = svmax
        fstats(3,j) = sumax
        fstats(4,j) = slmax
        fstats(5,j) = tsmax
        fstats(6,j) = -tnmin
        fstats(7,j) = tnmax
        fstats(8,j) = tarrmax
        estats(1,j) = efric
        estats(2,j) = estrain
        estats(3,j) = moment
    end if
end if

! write stats
if ( j > 0 .and. ( modulo( it, itio ) == 0 .or. it == nt ) ) then
    rr = timer( 2 )
    call rreduce2( gvstats, vstats, 'max', ip3root )
    if ( dofault ) then
        call rreduce2( gfstats, fstats, 'max', ip2root )
        call rreduce2( gestats, estats, 'sum', ip2root )
    end if
    if (sync) call barrier
    mptimer = mptimer + timer( 2 )
    if ( master ) then
        m = nt / itstats
        o = it / itstats - j
        gvstats = sqrt( gvstats )
        call rio1( fh(1), gvstats(1,:j), 'w', 'stats/amax.bin', m, o, mpout, verb )
        call rio1( fh(2), gvstats(2,:j), 'w', 'stats/vmax.bin', m, o, mpout, verb )
        call rio1( fh(3), gvstats(3,:j), 'w', 'stats/umax.bin', m, o, mpout, verb )
        call rio1( fh(4), gvstats(4,:j), 'w', 'stats/wmax.bin', m, o, mpout, verb )
        if ( dofault ) then
            gfstats(6,:j) = -gfstats(6,:j)
            call rio1( fh(5),  gfstats(1,:j), 'w', 'stats/samax.bin',   m, o, mpout, verb )
            call rio1( fh(6),  gfstats(2,:j), 'w', 'stats/svmax.bin',   m, o, mpout, verb )
            call rio1( fh(7),  gfstats(3,:j), 'w', 'stats/sumax.bin',   m, o, mpout, verb )
            call rio1( fh(8),  gfstats(4,:j), 'w', 'stats/slmax.bin',   m, o, mpout, verb )
            call rio1( fh(9),  gfstats(5,:j), 'w', 'stats/tsmax.bin',   m, o, mpout, verb )
            call rio1( fh(10), gfstats(6,:j), 'w', 'stats/tnmin.bin',   m, o, mpout, verb )
            call rio1( fh(11), gfstats(7,:j), 'w', 'stats/tnmax.bin',   m, o, mpout, verb )
            call rio1( fh(12), gfstats(8,:j), 'w', 'stats/tarrmax.bin', m, o, mpout, verb )
            call rio1( fh(13), gestats(1,:j), 'w', 'stats/efric.bin',   m, o, mpout, verb )
            call rio1( fh(14), gestats(2,:j), 'w', 'stats/estrain.bin', m, o, mpout, verb )
            call rio1( fh(15), gestats(3,:j), 'w', 'stats/moment.bin',  m, o, mpout, verb )
            do i = 1, j
                if ( gestats(3,i) > 0.0 ) then
                    gestats(3,i) = ( log10( gestats(3,i) ) - 9.05 ) / 1.5
                else
                    gestats(3,i) = -999
                end if
            end do
            call rio1( fh(16), gestats(3,:j), 'w', 'stats/mw.bin',      m, o, mpout, verb )
        end if
    end if
    j = 0
    if (sync) call barrier
    iotimer = iotimer + timer( 2 )
end if

end subroutine

end module

