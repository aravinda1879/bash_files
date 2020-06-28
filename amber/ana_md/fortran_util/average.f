      program one
      character infile*20, ls*5
      dimension dat(100000)
      integer eof
      real dat
      ls='ls'
      call system(ls)
!      write(6,*)'File need the average'
!      read(5,*)infile
      infile='239_surf.dat'
      open(unit=10,file=infile,status="old")
      n1=1
      n2=1
      tot=0
      do while(n1.lt.500)
       read(10,*)
       n1=n1+1
      end do
      do while(1.eq.1)
       read(10,*,iostat=eof)frame,val
       write(6,*)frame
       if (eof.lt.0) goto 500
       tot=val+tot
       dat(n2)=val
       n2=n2+1
      end do
 500  continue
      call avg(tot,n2,sig,sd)
      write(6,*)sig,sd,n2
      stop
      end 
      subroutine avg(tot,n2,sig1,sd1)
      real sig1,sd1
      dimension dat(100000)
       sd1=0
       sig1=tot/n
       do i=1,n2
        t1=(dat(i)-sig1)**2
        sd1=sd1+t1
       end do
       sd1=((1/n)*sd)**0.5
      return
      end
