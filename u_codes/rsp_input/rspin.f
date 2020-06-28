      program rspin
      character infile*20,of*20,sym*1
      open(unit=21, file='temp',status='unknown')
      write(6,*)'Enter how many conformations'
      read(5,*)n_c
      write(6,*)'Enter how many atoms in the system'
      read(5,*),n_a
      write(6,*)'Enter the output file name'
      read(5,*)of
      of=trim(of)//'.in'
      open(unit=20, file=of, status='unknown')
c writing the first few lines of input file
      write(20,*)'run#1'
      write(20,*)' &cntrl'
      write(20,505)'nmol =',n_c,','
      write(20,*)'ihfree=1,'
      write(20,*)'qwt=0.0005'
      write(20,*) 'iqopt=2,'
      write(20,*)' /'
c end writing
c Start writing atomic number and change state to in file
      do i = 1, n_c
        write(6,*)'conformation',i
        write(20,*)'1.0'
        write(20,504)' conformation',i
        write(6,*)'Enter gaussian input file name '
        read(5,*)infile
        write(21,506)n_c,n_a,infile
        open(unit = i,file=infile,status='old')
        do ii=1,5
          read(i,*)
        end do
        read(i,*)chg
        a=1
        nac=0
        do while (a.eq.1)
            nac=nac+1
            read(i,500,iostat=ieof)sym
            if (sym.eq.'C') then
                write(20,501) 6,0
            elseif (sym.eq.'O') then
                write(20,501) 8,0
            elseif (sym.eq.'H') then
                write(20,501) 1,0
            elseif (sym.eq.'S') then
                write(20,501) 32,0
            elseif (sym.eq.'N') then
                write(20,501) 7,0
            elseif (ieof.lt.0) then
                a=2
                nac=nac-1
            else
                nac=nac-1
            end if
        end do
        if(nac.eq.n_a) then
            write(6,*)'atomic count is ok'
        else
            write(20,*)'Atomic count is not ok'
        end if
        write(20,*)''
      end do
c Entering similarity details
      do i=1,n_a
        write(20,502) n_c
        do j=1,n_c
            write(20,503,advance='no') j, i
        end do
        write(20,*)''
      end do
 500  format(1x,a1)
 501  format(3x,i3,2x,i3)
 502  format(3x,i3)
 503  format(3x,i3,3x,i3)
 504  format(a14,i3)
 505  format(1x,a6,i3,a1)
 506  format(2x,i3,2x,i3,2x,a20)
      stop
      end
