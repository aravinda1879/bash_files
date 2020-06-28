      program join
      character if1*20, if2*20, of1*20
      read(5,*) if1,if2
      of1='t_'//trim(if1)
      open(unit=10, file=if1, status='old')
      open(unit=11,file=if2,status = 'old')
      open(unit=20, file=of1, status='unknown')
      do while(1.eq.1)
        read(10,*,end=200)n1, r1
        write(20,*)n1,r1
      end do
 200  do while (1.eq.1)
        read(11,*,end=201)n2,r2
        n2 = n1+n2
        write(20,*)n2,r2
      end do
 201  stop
      end
c terabithia
