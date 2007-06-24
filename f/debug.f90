
if ( debug == 10 .and. ip < 10 .and. nt < 10 ) then
i = 1000 * ( it + 1 ) + ip

  if ( it == 0 ) then
    j = i1core(1) 
    if ( ip == 0 ) uu(j,:,:,1) = 1.
    do l = i1node(3), i2node(3)
    do k = 1, nm(2)
      write( 010+i, * ) mr(:,k,l)
      write( 020+i, * ) gam(:,k,l)
    end do
    end do
    do l = i1cell(3), i2cell(3)
    do k = 1, nm(2)-1
      write( 030+i, * ) lam(:,k,l)
      write( 040+i, * ) mu(:,k,l)
      write( 050+i, * ) yy(:,k,l)
    end do
    end do
  end if
  do l = i1node(3), i2node(3)
  do k = 1, nm(2)
    write( 110+i, * ) vv(:,k,l,1)
    write( 120+i, * ) vv(:,k,l,2)
    write( 130+i, * ) vv(:,k,l,3)
    write( 210+i, * ) uu(:,k,l,1)
    write( 220+i, * ) uu(:,k,l,2)
    write( 230+i, * ) uu(:,k,l,3)
  end do
  end do
  do l = i1cell(3), i2cell(3)
  do k = 1, nm(2)-1
    write( 310+i, * ) w1(:,k,l,1)
    write( 320+i, * ) w1(:,k,l,2)
    write( 330+i, * ) w1(:,k,l,3)
    write( 340+i, * ) w2(:,k,l,1)
    write( 350+i, * ) w2(:,k,l,2)
    write( 360+i, * ) w2(:,k,l,3)
  end do
  end do


  do l = i1node(3), i2node(3)
  do k = 1, nm(2)
    write( 410+i, * ) w1(:,k,l,1)
    write( 420+i, * ) w1(:,k,l,2)
    write( 430+i, * ) w1(:,k,l,3)
  end do
  end do
