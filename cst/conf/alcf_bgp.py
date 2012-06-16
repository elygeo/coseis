"""
ALCF IBM Blue Gene/P

intrepid.alcf.anl.gov   /intrepid-fs0/
challenger.alcf.anl.gov /intrepid-fs0/
surveyor.alcf.anl.gov   /gpfs/home

.softevnrc:
PYTHONPATH += $HOME/coseis
PATH += $HOME/coseis/bin
PATH += /gpfs/home/gely/local-$HOSTTYPE/bin
MANPATH += /gpfs/home/gely/local-$HOSTTYPE/man
PATH += /bgsys/drivers/ppcfloor/comm/xl/bin
+git-1.7.6.4

.basshrc:
PS1="[\u@${mybgp}:\w]\$ "
alias qdev='isub -q default -n 16 -t 60'
alias quota='/usr/lpp/mmfs/bin/mmlsquota'

useful:
qstat
cbank
projects
bg-listjobs
"""

core_range = [1, 2, 4]
maxram = 2048
host_opts = {
    'challenger': {'maxnodes': 512,   'maxtime': 60,  'queue': 'prod-devel'},
    'surveyor':   {'maxnodes': 1024,  'maxtime': 60,  'queue': 'default'},
    'intrepid':   {'maxnodes': 40960, 'maxtime': 720, 'queue': 'prod'},
}

compiler_c = 'mpixlcc_r'
compiler_f = 'mpixlf2003_r'
compiler_opts = {
    'f': '-qlanglvl=2003pure -qsuppress=cmpmsg -qmaxmem=-1',
    'g': '-C -O0 -g',
    't': '-C',
    'p': '-O -p -pg',
    'h': '-O /home/morozov/lib/libmpihpm.a',
    'O': '-O -qarch=450d -qtune=450',
    '8': '-qrealsize=8',
}

launch = {
    's_exec':  'cobalt-mpirun -mode vn -verbose 2 -np 1 {command}',
    'm_exec':  'cobalt-mpirun -mode vn -verbose 2 -np {nproc} {command}',
    'submit':  'qsub -O {name} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script {name}.sh',
    'submit2': 'qsub -O {name} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script --dependenices {depend} "{name}.sh"',
}

