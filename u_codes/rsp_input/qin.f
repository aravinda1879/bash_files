      program qin
      character infile*20, c*12, du*100
      real atmid(50)
      open(unit=10, file='temp', status='old')
      open(unit=20, file='temp_1', status='new')
      read(10,501)n_c,n_a
      write(6,*)'Enter rsp input file name'
      read(5,*)infile
      open(unit=11, file=infile, status='old')
      write(6,*)'Enter atom IDs of cap'
      read(5,503)du
      write(20,503)du
      do i=1,n_c
            read(11,500,iostat=ica)c
            if(c.eq.'conformation') then
                  do ii=1,n_a
                    read(11,502,advance='no')n,m
                    if (atmid(ii).eq.n) then
                        write(11,502)n,-1
                        read(11,502)
                    else
                        read(11,502)
                    end if
                  end do
            end if
      end do

 500  format(2x,a12)
 501  format(2x,i3,2x,i3)
 502  format(3x,i3,3x,i3)
 503  format(a100)
      stop
      end program qin
