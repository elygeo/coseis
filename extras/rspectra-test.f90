program main
integer :: n
real :: z(3), u(10) = 1.0, dt = 0.1, w = 1.0, d = 0.05
n = size( u )
call rspectra( z, u, dt, w, d, n )
print *, z
end program

