"""
Wat2Q IBM Blue Gene/Q

install location:
grotius.watson.ibm.com:/gpfs/DDNgpfs1/kmager/scratch/

.soft:
PYTHONPATH += $HOME/sord/gely-coseis-v3.2-615-g6a39bb8/gely-coseis-6a39bb8
PATH += $HOME/sord/gely-coseis-v3.2-615-g6a39bb8/gely-coseis-6a39bb8/bin
+mpiwrapper-xl
@default
"""

# machine properties
maxnodes = 1024
maxcores = 16
maxram = 16384

# MPI
ppn_range = [1, 2, 4, 8, 16, 32]
nthread = 1
launch = 'runjob --exe {command} -n {nproc} -p {ppn} --verbose=INFO --block $COBALT_PARTNAME ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE --envs BG_SHAREDMEMSIZE=32MB PAMID_VERBOSE=1 VPROF_PROFILE=yes\n'

# MPI + OpenMP
ppn_range = [1]
nthread = 32
launch = 'runjob --exe {command} -n {nproc} -p {ppn} --verbose=INFO --block $COBALT_PARTNAME ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE --envs BG_SHAREDMEMSIZE=32MB PAMID_VERBOSE=1 VPROF_PROFILE=yes OMP_NUM_THREADS={nthread}\n'

# job submission
notify = '-M {email}'
submit =  'qsub {notify} -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1:VPROF_PROFILE=yes {submit_flags} "{name}.sh"'
submit2 = 'qsub {notify} -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1:VPROF_PROFILE=yes --dependenices {depend} {submit_flags} "{name}.sh"'

