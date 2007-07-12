! Command line arguments

integer function command_argument_count()
integer :: iargc
command_argument_count = iargc()
end function

subroutine get_command_argument(i,val)
integer, intent(in) :: i
character(len=*), intent(out) :: val
call getarg(i,val)
end subroutine

