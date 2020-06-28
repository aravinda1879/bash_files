      program one
      real aa(:)
      allocatable aa
      open(unit = 10, file='a1', status='old')
      read(10,100) aa
 100  format(a100)
      write(6,*) aa(2),aa(7),aa(3)
      stop
      end
