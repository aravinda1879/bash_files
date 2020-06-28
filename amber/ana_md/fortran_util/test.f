      program one
      dimension a(5)
      real a, b(5)
      character infile*20,outfile*20
      dimension rind(13),rtot(13),avg(13)
      real rind,rtot,avg
      integer bin
      infile='6nm_3nm.dat'
      outfile='avg.dat'
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
        i2=i
        rtot=rtot+rind
       end do
       cnt=cnt+(bin*5/1000)
 300   avg= rtot/i2
       write(20,*)a(1),(a(2*i)+a(2*i+1),i=1,6)
      end do


      b=(/1,2,3,4,5/)
      do i=1,5
       a(i) = 5
      end do
      a=a+5
      write(6,*) a,b
      a=a+b
c      (a(i),i=1,15)=(a(i)/5,i=1,15)
      write(6,*)(a(i)+a(i+1),i=1,4)
c      (a(i),i=1,15)=(a(i)/5,i=1,15)
      stop
      end

