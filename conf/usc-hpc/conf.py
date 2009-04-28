notes = """
USC HPC

http://www.usc.edu/hpcc/
Add these to your .cshrc:
    source /usr/usc/mpich/default/setup.csh
    source /usr/usc/globus/default/setup.csh
Add these to your .bashrc:
    source /usr/usc/mpich/default/setup.sh
    source /usr/usc/globus/default/setup.sh
Run from disks located at HPC:
    /auto/scec-00
    /auto/rcf-104
I/O to temporary space:
    /scratch
alias showme='qstat -n | grep -E "Queue|-----|nbns"; qstat -n | grep scec'

--disable-devdebug
--with-device=ch_mx
-prefix=/usr/usc/mpich/1.2.7..7/mx-gnu
-opt=-O2 -c++=/usr/bin/g++
--enable-sharedlib
--libdir=/usr/usc/mpich/1.2.7..7/mx-gnu/lib
--with-romio=--with-file-system=nfs+ufs+pvfs2
-lib=
-lmyriexpress
-lpthread
-lpvfs2
-lpthread
-L/usr/usc/mpich/1.2.7..7/mx-gnu/extras/lib
-L/usr/X11R6/lib
-Wl,-rpath
-Wl,/usr/usc/mpich/1.2.7..7/mx-gnu/extras/lib
-Wl,-rpath
-Wl,/usr/usc/mpich/1.2.7..7/mx-gnu/lib
-c++linker=/usr/bin/g++
"""
login = 'hpc-login1.usc.edu'
hosts = [ 'hpc-login1', 'hpc-login2' ]
queue = 'largemem'; maxnodes = 5;   maxcores = 8; maxram = 63000; maxtime = 336, 00
queue = 'large';    maxnodes = 256; maxcores = 8; maxram = 11000; maxtime = 24, 00
queue = 'quick';    maxnodes = 4;   maxcores = 4; maxram = 3500;  maxtime = 1, 00
queue = 'main';     maxnodes = 378; maxcores = 4; maxram = 3500;  maxtime = None
queue = 'quick';    maxnodes = 4;   maxcores = 8; maxram = 11000; maxtime = 1, 00
queue = 'main';     maxnodes = 382; maxcores = 8; maxram = 11000; maxtime = None
queue = 'scec';     maxnodes = 100; maxcores = 2; maxram = 1500;  maxtime = 336, 00
queue = 'nbns';     maxnodes =  48; maxcores = 8; maxram = 11000; maxtime = 336, 00
rate = 1.1e6
mode = 'm'

