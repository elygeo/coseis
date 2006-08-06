         subroutine readpts(kerr)
c-----read points of interest-----------------
         include 'in.h'
         kerr=0
         open(15,file='btestin',status='old',err=1099)
c        nn=51456
         read(15,*)nn
         do 150 i=1,nn
         read(15,*)rlat(i),rlon(i),rdep(i)
c now read in meters
         rdep(i)=rdep(i)*3.2808399
         if(rdep(i).lt.rdepmin)rdep(i)=rdepmin
150      continue
         close(15)
         go to 1088
1099     kerr=1
1088     return
         end

         subroutine writepts(kerr)
c----write points of interest-----------------
         include 'in.h'
         kerr=0
         open(17,file='btestout',status='new')
         do 155 i=1,nn
          rdep(i)=rdep(i)/3.2808399
          write(17,77)rlat(i),rlon(i),rdep(i),alpha(i)
     1    ,beta(i),rho(i)
77       format(f8.5,1x,f10.5,1x,f9.2,1x,f8.1,1x,f8.1,1x,f8.1)
155      continue
         close(17)
         return
         end

