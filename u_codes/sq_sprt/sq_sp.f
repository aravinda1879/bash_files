      program sq_sp
      character infile*5, a1*100
      write(6,*)'enter the file name'
      infile='fasta'
      s = 10
      open(unit=10,file=infile,status='old')
      open(unit=20,file='3_seq',status='unknown')
      read(unit = 10, '(a)', advance='no', size = s, EOR = 11, end=22) a1
 11   continue
 22   continue
      write(6,*)a1
      stop
      end


