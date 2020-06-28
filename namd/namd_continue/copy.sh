#!/bin/bash
for i in `seq 5 10`;
do 
prefix=b10kRimd${i}
rsync -avP aravinda1879@sftp.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/${prefix}_5ps .
done
