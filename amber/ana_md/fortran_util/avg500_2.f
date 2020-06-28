      program one
      real rind(13),rtot(13),avg(13)
      character infile*20,outfile*20
      integer bin
      infile='6nm_3nm.dat'
      outfile='avg.dat'
      open(unit=10,file=infile,status='old')
      open(unit=20,file=outfile,status='unknown')
      read(10,*)
      t=0
      i2=0
      bin=500
      cnt=0
      rtot=0
      rind=0
      do while (t.eq.0)
       do i=1,bin
        read(10,*,iostat=ieof)(rind(j),j=1,13)
        if (ieof.lt.0) then
         i2=i-1
         t=1
         goto 300
        end if
        cnt=cnt+1
        i2=i
        rtot=rtot+rind
       end do
 300   avg= rtot/i2
       write(20,*,advance ="no")cnt
       do i=1,3
        write(20,*,advance="no"),(avg(2*i)+avg(2*i+1),(avg(2*i+6)+avg(2*i+7))
       end do 
       rtot=0
       rind=0
      end do
      stop
      end 
       
       
       
      
