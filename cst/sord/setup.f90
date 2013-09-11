! setup model dimensions
module setup
implicit none
contains

subroutine setup_dimensions
use globals
use collective
use utilities
integer :: nl(3)
character(32) :: filename

if (sync) call barrier
if (master) print *, clock(), 'Setup dimensions'

! dimensions
dx = delta(1:3)
dt = delta(4)
nn = shape_(1:3)
nt = max(shape_(4), 0)

! fault normal
ifn = abs(faultnormal)

! partition for parallelization
nl3 = (nn - 1) / nproc3 + 1
nhalo = 1
if (ifn /= 0) nhalo(ifn) = 2
nl3 = max(nl3, nhalo)
nproc3 = (nn - 1) / nl3 + 1
call rank(ip, ip3, nproc3)

! master process
master = ip == 0

! offset from local to global indices
nnoff = nl3 * ip3 - nhalo

! process rank for hypocenter 
ip3hypo = floor((ihypo - 1.0) / nl3)

! size of arrays
nl = min(nl3, nn - nnoff - nhalo)
nm = nl + 2 * nhalo

! boundary conditions
i1bc = 1  - nnoff
i2bc = nn - nnoff

! non-overlapping core region
i1core = 1  + nhalo
i2core = nm - nhalo

! node region
i1node = max(i1bc, 2)
i2node = min(i2bc, nm - 1)

! cell region
i1cell = max(i1bc, 1)
i2cell = min(i2bc - 1, nm - 1)

! pml region
i1pml = i1pml - nnoff
i2pml = i2pml - nnoff

! map rupture index to local indices, and test if fault on this process
irup = 0
if (ifn /= 0) then
    irup = floor(ihypo(ifn) + 0.000001) - nnoff(ifn)
    if (irup + 1 < i1core(ifn) .or. irup > i2core(ifn)) ifn = 0
end if

! debugging
sync = debug > 1
if (debug > 2) then
    write (filename, "(a,i6.6,a)") 'debug/db', ip, '.json'
    open (1, file=filename, status='replace')
    write (1, '(a)') '{'
    write (1, "(a, i8, ',')") &
        '"ifn":    ', ifn,    '"irup":   ', irup,   '"ip":     ', ip
    write (1, "(a, '[', i8, ',', i8, ',', i8, '],')") &
        '"bc1":    ', bc1,    '"bc2":    ', bc2,    '"ip3":    ', ip3, &
        '"nhalo":  ', nhalo,  '"nm":     ', nm,     '"nn":     ', nn, &
        '"nnoff":  ', nnoff,  '"nproc3": ', nproc3, &
        '"i1bc":   ', i1bc,   '"i1cell": ', i1cell, '"i1core": ', i1core, &
        '"i1node": ', i1node, '"i1pml":  ', i1pml, &
        '"i2bc":   ', i2bc,   '"i2cell": ', i2cell, '"i2core": ', i2core, &
        '"i2node": ', i2node, '"i2pml":  ', i2pml
    write (1, '(a)') '}'
    close (1)
end if

end subroutine

end module

