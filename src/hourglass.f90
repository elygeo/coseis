! hourglass corrections
module m_hourglass
implicit none
contains

! node to cell
subroutine hourglassnc( df, f, iq, i, i1, i2 )
real, intent(out) :: df(:,:,:)
real, intent(in) :: f(:,:,:,:)
integer, intent(in) :: iq, i, i1(3), i2(3)
integer :: j, k, l

if ( any( i1 > i2 ) ) return

select case( iq )
case( 1 )
    do l = i1(3), i2(3)
    do k = i1(2), i2(2)
    do j = i1(1), i2(1)
        df(j,k,l) = &
          f(j,k,l,i) + f(j+1,k+1,l+1,i) &
        + f(j,k+1,l+1,i) + f(j+1,k,l,i) &
        - f(j+1,k,l+1,i) - f(j,k+1,l,i) &
        - f(j+1,k+1,l,i) - f(j,k,l+1,i)
    end do
    end do
    end do
case( 2 )
    do l = i1(3), i2(3)
    do k = i1(2), i2(2)
    do j = i1(1), i2(1)
        df(j,k,l) = &
          f(j,k,l,i) + f(j+1,k+1,l+1,i) &
        - f(j,k+1,l+1,i) - f(j+1,k,l,i) &
        + f(j+1,k,l+1,i) + f(j,k+1,l,i) &
        - f(j+1,k+1,l,i) - f(j,k,l+1,i)
    end do
    end do
    end do
case( 3 )
    do l = i1(3), i2(3)
    do k = i1(2), i2(2)
    do j = i1(1), i2(1)
        df(j,k,l) = &
          f(j,k,l,i) + f(j+1,k+1,l+1,i) &
        - f(j,k+1,l+1,i) - f(j+1,k,l,i) &
        - f(j+1,k,l+1,i) - f(j,k+1,l,i) &
        + f(j+1,k+1,l,i) + f(j,k,l+1,i)
    end do
    end do
    end do
case( 4 )
    do l = i1(3), i2(3)
    do k = i1(2), i2(2)
    do j = i1(1), i2(1)
        df(j,k,l) = &
          f(j,k,l,i) - f(j+1,k+1,l+1,i) &
        + f(j,k+1,l+1,i) - f(j+1,k,l,i) &
        + f(j+1,k,l+1,i) - f(j,k+1,l,i) &
        + f(j+1,k+1,l,i) - f(j,k,l+1,i)
    end do
    end do
    end do
end select

end subroutine

!------------------------------------------------------------------------------!

! cell to node
subroutine hourglasscn( df, f, iq, i1, i2 )
real, intent(out) :: df(:,:,:)
real, intent(in) :: f(:,:,:)
integer, intent(in) :: iq, i1(3), i2(3)
integer :: j, k, l

if ( any( i1 > i2 ) ) return

select case( iq )
case( 1 )
    do l = i1(3), i2(3)
    do k = i1(2), i2(2)
    do j = i1(1), i2(1)
        df(j,k,l) = &
          f(j,k,l) + f(j-1,k-1,l-1) &
        + f(j,k-1,l-1) + f(j-1,k,l) &
        - f(j-1,k,l-1) - f(j,k-1,l) &
        - f(j-1,k-1,l) - f(j,k,l-1)
    end do
    end do
    end do
case( 2 )
    do l = i1(3), i2(3)
    do k = i1(2), i2(2)
    do j = i1(1), i2(1)
        df(j,k,l) = &
          f(j,k,l) + f(j-1,k-1,l-1) &
        - f(j,k-1,l-1) - f(j-1,k,l) &
        + f(j-1,k,l-1) + f(j,k-1,l) &
        - f(j-1,k-1,l) - f(j,k,l-1)
    end do
    end do
    end do
case( 3 )
    do l = i1(3), i2(3)
    do k = i1(2), i2(2)
    do j = i1(1), i2(1)
        df(j,k,l) = &
          f(j,k,l) + f(j-1,k-1,l-1) &
        - f(j,k-1,l-1) - f(j-1,k,l) &
        - f(j-1,k,l-1) - f(j,k-1,l) &
        + f(j-1,k-1,l) + f(j,k,l-1)
    end do
    end do
    end do
case( 4 )
    do l = i1(3), i2(3)
    do k = i1(2), i2(2)
    do j = i1(1), i2(1)
        df(j,k,l) = &
          f(j,k,l) - f(j-1,k-1,l-1) &
        + f(j,k-1,l-1) - f(j-1,k,l) &
        + f(j-1,k,l-1) - f(j,k-1,l) &
        + f(j-1,k-1,l) - f(j,k,l-1)
    end do
    end do
    end do
end select

end subroutine

end module

