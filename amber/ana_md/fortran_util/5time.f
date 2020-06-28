	program one
	character infile*20, outfile*20
	write(6,*) "input file name"
	read(5,*) infile
	write(6,*) "output file name"
	read(5,*) outfile
	open(unit=10,file=infile,status="old")
	open(unit=20,file=outfile,status="unknown")
	read (10,*)
	do while (1.eq.1)
	 read(10,*,iostat=ieof) a1,a2
	 if(ieof.lt.0) goto 300
	 a1=a1*5
	 write(20,*)a1,a2
	end do
 300	continue
	stop
	end
