	program one
	character infile*20
	write(6,*)'b factor dat file'
	read(5,*)infile
	open(unit=10,file=infile,status="old")
	open(unit=20,file="bfactor_all_new.dat",status="unknown")
	read(10,*)
	acount=1
	do while(1.eq.1)
	 read(10,*)a1,a2
	 write(20,*)acount,a2
	 acount=acount+1
	end do
	stop 
	end
