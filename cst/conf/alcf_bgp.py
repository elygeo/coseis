"""
ALCF IBM Blue Gene/P Systems

Login:
ssh intrepid.alcf.anl.gov
ssh challenger.alcf.anl.gov
ssh surveyor.alcf.anl.gov

File systems:
/intrepid-fs0/:  Intrepid, Challenger, Eureka
/gpfs/home: Surveyor, Gadzooks

.softevnrc:
PYTHONPATH += $HOME/coseis
PATH += $HOME/coseis/bin
PATH += /gpfs/home/gely/local-$HOSTTYPE/bin
MANPATH += /gpfs/home/gely/local-$HOSTTYPE/man
PATH += /bgsys/drivers/ppcfloor/comm/xl/bin
+git-1.7.6.4
+ddt

.basshrc:
PS1="[\u@${mybgp}:\w]\$ "
alias qdev='isub -q default -n 16 -t 60'
alias quota='/usr/lpp/mmfs/bin/mmlsquota'

Useful commands:
qstat
cbank
projects
bg-listjobs
"""

maxram = 2 * 1024
maxcores = 4
host_opts = {
    'challenger': {'maxnodes': 512,       'maxtime': 60,      'queue': 'prod-devel'},
    'surveyor':   {'maxnodes': 1024,      'maxtime': 60,      'queue': 'default'},
    'intrepid':   {'maxnodes': 1024 * 40, 'maxtime': 60 * 12, 'queue': 'prod'},
}

compiler_c = 'mpixlcc_r'
compiler_f = 'mpixlf2003_r'
compiler_opts = {
    'f': '-qlanglvl=2003pure -qsuppress=cmpmsg -qmaxmem=-1',
    'g': '-C -O0 -g',
    't': '-C',
    'p': '-O -p /home/morozov/lib/libmpihpm.a',
    'O': '-O -qarch=450d -qtune=450',
    '8': '-qrealsize=8',
}

launch = {
    's_exec':  'cobalt-mpirun -mode vn -verbose 2 -np 1 {command}',
    'm_exec':  'cobalt-mpirun -mode vn -verbose 2 -np {nproc} {command}',
    'submit':  'qsub -O {name} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script {name}.sh',
    'submit2': 'qsub -O {name} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script --dependenices {depend} "{name}.sh"',
}

