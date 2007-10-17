! Debugging
! Copyright 2007 Geoffrey Ely
! This software is released under the GNU General Public License
module m_debug_out
contains
subroutine debug_out( pass )
use m_globals
implicit none
integer, intent(in) :: pass
integer :: i, k, l
if ( it > 8 ) return

i = 10000 * ( it + 1 ) + ip
select case( pass )
case( 0 )
  !i = i1core(1) 
  !if ( ip == 0 ) uu(i,:,:,1) = 1.
  do l = 1, nm(3)
  write( 010+i, * ) ip3, 'xn1', l
  write( 020+i, * ) ip3, 'xn2', l
  write( 030+i, * ) ip3, 'xn3', l
  do k = 1, nm(2)
    write( 010+i, * ) w1(:,k,l,1)
    write( 020+i, * ) w1(:,k,l,2)
    write( 030+i, * ) w1(:,k,l,3)
  end do
  end do
  do l = 1, nm(3)-1
  write( 040+i, * ) ip3, 'xc1', l
  write( 050+i, * ) ip3, 'xc2', l
  write( 060+i, * ) ip3, 'xc3', l
  do k = 1, nm(2)-1
    write( 040+i, * ) w2(:,k,l,1)
    write( 050+i, * ) w2(:,k,l,2)
    write( 060+i, * ) w2(:,k,l,3)
  end do
  end do
case( 1 )
  if ( it == 0 ) then
    do l = 1, nm(3)
    write( 070+i, * ) ip3, 'mr', l
    write( 080+i, * ) ip3, 'gam', l
    do k = 1, nm(2)
      write( 070+i, * ) mr(:,k,l)
      write( 080+i, * ) gam(:,k,l)
    end do
    end do
    do l = 1, nm(3)-1
    write( 090+i, * ) ip3, 'lam', l
    do k = 1, nm(2)-1
      write( 090+i, * ) lam(:,k,l)
    end do
    end do
  else
    do l = 1, nm(3)
    write( 110+i, * ) ip3, 'v1', it, l
    write( 120+i, * ) ip3, 'v2', it, l
    write( 130+i, * ) ip3, 'v3', it, l
    write( 210+i, * ) ip3, 'u1', it, l
    write( 220+i, * ) ip3, 'u2', it, l
    write( 230+i, * ) ip3, 'u3', it, l
    do k = 1, nm(2)
      write( 110+i, * ) vv(:,k,l,1)
      write( 120+i, * ) vv(:,k,l,2)
      write( 130+i, * ) vv(:,k,l,3)
      write( 210+i, * ) uu(:,k,l,1)
      write( 220+i, * ) uu(:,k,l,2)
      write( 230+i, * ) uu(:,k,l,3)
    end do
    end do
    do l = 1, nm(3)-1
    write( 310+i, * ) ip3, 'xx', it, l
    write( 320+i, * ) ip3, 'yy', it, l
    write( 330+i, * ) ip3, 'zz', it, l
    write( 340+i, * ) ip3, 'yz', it, l
    write( 350+i, * ) ip3, 'zx', it, l
    write( 360+i, * ) ip3, 'xy', it, l
    do k = 1, nm(2)-1
      write( 310+i, * ) w1(:,k,l,1)
      write( 320+i, * ) w1(:,k,l,2)
      write( 330+i, * ) w1(:,k,l,3)
      write( 340+i, * ) w2(:,k,l,1)
      write( 350+i, * ) w2(:,k,l,2)
      write( 360+i, * ) w2(:,k,l,3)
    end do
    end do
  end if
case( 2 )
  do l = 1, nm(3)
  write( 410+i, * ) ip3, 'a1', it, l
  write( 420+i, * ) ip3, 'a2', it, l
  write( 430+i, * ) ip3, 'a3', it, l
  do k = 1, nm(2)
    write( 410+i, * ) w1(:,k,l,1)
    write( 420+i, * ) w1(:,k,l,2)
    write( 430+i, * ) w1(:,k,l,3)
  end do
  end do
end select
end subroutine
end module
