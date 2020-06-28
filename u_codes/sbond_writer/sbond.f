      program cys
      character rsname*3,aa1*6,aa2*3,aa3*3,aa4*1,aa5*2
      character infile*15,outfile*15
      loop=1
      write(6,*)'enter the file name'
c      read(5,*)infile
      infile='opg-crd'
      outfile=trim(infile)//'_e.pdb'
      infile=trim(infile)//'.pdb'
      open(unit=10,file=infile,status='old')
      open(unit=20,file=outfile,status='unknown')  
      do while(loop.eq.1)
        read(10,500,iostat=is)aa1,ii1,aa2,aa3,aa4,ii3,ff1,ff2,ff3 
        if (is.lt.0) goto 200
c        write(6,*)'a'
        if (trim(aa1).eq.'ATOM') then
c          write(20,500) aa1,ii1,aa2,aa3,aa4,ii3,ff1,ff2,ff3 
          if(aa3.eq.'CYS') then
            aa3='CYX'
          end if
            write(20,500) aa1,ii1,aa2,aa3,aa4,ii3,ff1,ff2,ff3
        endif
      end do
 200  continue
 500  format(a6,1x,i4,2x,a3,1x,a3,1x,a,1x,i3,3x,3f9.3)
      stop
      end
