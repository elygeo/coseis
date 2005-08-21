#!/bin/bash -e
#------------------------------------------------------------------------------#

mpi=guess
debug=no
logging=no

while getopts spgl opt; do
  case $opt in
  s) mpi=no ;;
  p) mpi=yes ;;
  g) debug=yes ;;
  l) logging=yes ;;
  esac
done

if [ "$logging" = no ]; then
  #"$0" "$@" -l 2>&1 | tee log
  script -c "$0 $@ -l"
  exit
fi

echo "SORD - Support Opperator Rupture Dynamics"
date
rundir=$( /bin/pwd )

infile="in"
[ -r "$infile" ] || exit

n=( 1 1 1 1 )
p=( 1 1 1 )

while read key params; do
  set -- $params
  case "$key" in
  n)     n=( $1 $2 $3 $4 ) ;;
  nproc) p=( $1 $2 $3 ) ;;
  esac
done < "$infile"

floatsize=4
points=$(( n[0] * n[1] * n[2] ));
procs=$(( p[0] * p[1] * p[2] ));
ram=$(( points / procs * floatsize * 22 / 1024 / 1024 ))
wt=$(( points / procs / 40000 + 1 ))

if   [ $wt -gt 5400 ]; then wt="$(( wt / 3600 + 1 )):00:00"
elif [ $wt -gt 90   ]; then wt="$(( wt /   60 + 1 )):00"
fi

[ $mpi = guess -a $procs -eq 1 ] && mpi=no
[ $mpi = guess -a $procs -gt 1 ] && mpi=yes

osname=$( uname )

if   [ "${HOSTNAME:0:2}" = ds ]; then machine="datastar"
elif [ "${HOSTNAME:0:2}" = tg ]; then machine="teragrid"
elif [ "$HOSTNAME" = master ];   then machine="babieca"
fi

cat << END
Total points: $points
Processors: $procs
Ram per proc: $ram
Wall clock: $wt
END

#------------------------------------------------------------------------------#
# Create makefile and compile code

OBJECT="\\
  globals.o \\
  dfcn.o \\
  dfnc.o \\
  hgcn.o \\
  hgnc.o \\
  snormals.o \\
  utils.o \\
  inputs.o \\
  gridgen.o \\
  matmodel.o \\
  vstep.o \\
  wstep.o \\
  output.o \\
  fault.o"

OPTFLAGS=-O

if [ $mpi = no ]; then
  OBJECT="$OBJECT \\
  main.o"
  FC=f95
  CC=cc
else
  OBJECT="$OBJECT \\
  pmain.o \\
  mpisetup.o \\
  mpioutput.o"
  FC=mpif95
  CC=mpicc
fi

case $osname in
Linux)
  OPTFLAGS=-O3
  OPTFLAGS=
  ;;
SunOS)
  OPTFLAGS=-fast
  ;;
esac

if [ $debug = yes ]; then
  OPTFLAGS=-g
fi

case $machine in
datastar)
  FC=mpxlf95_r
  CC=mpcc_r
  OPTFLAGS="-O3 -qstrict -qarch=pwr4 -qtune=pwr4 -q64"
  [ $debug = yes ] && OPTFLAGS="-g -qflttrap"
  ;;
babieca)
  [ $mpi = no ] && FC=pgf95
  ;;
esac

cat << END > tmp
FC = $FC
CC = $CC
FFLAGS = $OPTFLAGS
OBJECT = $OBJECT

sord: \$(OBJECT) makefile
	\$(FC) \$(FFLAGS) \$(OBJECT) -o sord
	./tarball.sh

clean:
	rm *.o *.mod

%.o: %.f95 makefile
	\$(FC) \$(FFLAGS) -c \$< -o \$@

END

[ ! -f makefile ] && touch makefile
[ "$( diff tmp makefile )" != "" ] && mv tmp makefile
gmake

#------------------------------------------------------------------------------#
# Save metadata and sorce code

[ -e meta ] && rm -fr meta
mkdir meta
perl -e 'print pack('V',1) eq pack('L',1) ? "little\n":"big\n"' > meta/endian
cat << END > meta/data
name:     $( finger $LOGNAME | sed -n 's/^.*e: //p' )
logname:  ${LOGNAME}
date:     $( date )
machine:  $machine
hostname: ${HOSTNAME}
osname:   $( uname -a )
points:   $points
procs:    $procs
END
srcbase=$( basename "$rundir" )
cp "${srcbase}.tgz" meta/
cp -f sord meta/

#------------------------------------------------------------------------------#
# Machine specific batch submission and run commands

case $machine in

#------------------#
teragrid)

ppn=2;
[ $ppn -gt $procs ] && ppn=$procs
nodes=$(( procs / ppn + ( procs % ppn > 0 ? 1 : 0 ) ))
cmd=""
[ $mpi = yes ] && cmd="mpirun -v -machinefile \$PBS_NODEFILE -np $procs"

cat << END > batch.sh
#!/bin/csh
#PBS -q dque
#PBS -N sord_job
#PBS -l nodes=$nodes:ppn=$ppn
#PBS -l walltime=$wt
#PBS -o stdout
#PBS -e stderr
#PBS -V
cd $rundir
time $cmd ./sord
END

cat << END > submit.sh
#!/bin/bash
# teragrid batch submission
qsub batch.sh
END

;;

#------------------#
babieca)

ppn=2
[ $ppn -gt $procs ] && ppn=$procs
nodes=$(( procs / ppn + ( procs % ppn > 0 ? 1 : 0 ) ))
cmd=""
[ $mpi = yes ] && cmd="mpiexec -np $procs"

cat << END > batch.sh
#!/bin/sh
#PBS -q workq
#PBS -N sord_job
#PBS -l nodes=$nodes:ppn=$ppn
#PBS -o stdout
#PBS -e stderr
#PBS -V
sleep 2
cd $rundir
time $cmd ./sord
END

cat << END > submit.sh
#!/bin/bash
# babieca batch submission (up to 19 procs):
# other useful commands: pbsnodes -a, pingd, qstat, qdel
qsub batch.sh
END

cat << END > run.sh
#!/bin/bash
# run interactively (you really should use the batch system)
mpirun -np $procs ./sord | tee -a log
END

;;

#------------------#
datastar)

ppn=8;
[ $ppn -gt $procs ] && ppn=$procs
nodes=$(( procs / ppn + ( procs % ppn > 0 ? 1 : 0 ) ))

cat << END > batch.sh
#!/bin/bash
#@ environment = COPY_ALL;\\
AIXTHREAD_COND_DEBUG=OFF;\\
AIXTHREAD_MUTEX_DEBUG=OFF;\\
AIXTHREAD_RWLOCK_DEBUG=OFF;\\
AIXTHREAD_SCOPE=S;\\
MP_ADAPTER_USE=dedicated;\\
MP_CPU_USE=unique;\\
MP_CSS_INTERRUPT=no;\\
MP_EAGER_LIMIT=65536;\\
MP_EUIDEVELOP=min;\\
MP_EUIDEVICE=sn_single;\\
MP_EUILIB=us;\\
MP_POLLING_INTERVAL=100000;\\
MP_PULSE=0;\\
MP_SHARED_MEMORY=yes;\\
MP_SINGLE_THREAD=no;\\
RT_GRQ=ON;\\
SPINLOOPTIME=0;\\
YIELDLOOPTIME=0;
#@ wall_clock_limit = $wt
#@ class = normal
#@ node_usage = not_shared
#@ notify_user = $LOGNAME
#@ node = $nodes
#@ tasks_per_node = $ppn
#@ job_type = parallel
#@ network.MPI = sn_single,not_shared,US,HIGH
#@ notification = always
#@ job_name = job.dfm
#@ output = stdout
#@ error = stderr
#@ initialdir = $rundir
#@ queue
cd $rundir
poe ./sord
END

cat << END > submit.sh
#!/bin/bash
# datastar batch submition (up to 1408 procs, 2816 GB):
# other useful commands:
# llcancel <jobID>, llq, llq -s <jovID>, showq, reslist
llsubmit batch.sh
END

cat << END > run.sh
#!/bin/bash
# datastar interactive (up to 32 procs, 64 GB):
if [ \`hostname\` != ds100 ]; then
  echo "Error: to run interactively you must first ssh dspoe"
  exit
fi
poe ./sord -tasks_per_node $ppn -nodes $nodes -rmpool 1 -euilib us -euidevice sn_single | tee -a log
#totalview poe -a ./sord -tasks_per_node $ppn -nodes $nodes -rmpool 1 -euilib us -euidevice sn_single
END

if [ $( pwd | grep -v gpfs ) ]; then
  echo "Error: must run from a subdirectory of /gpfs/"
  exit
fi
;;

#------------------#
*)

if [ $debug = yes ]; then
  if [ $mpi = no ]; then
    echo "ddd ./sord" > run.sh
  else
    echo "mpirun -dbg=ddd -np $procs ./sord" > run.sh
  fi
else
  if [ $mpi = no ]; then
    echo "time ./sord | tee -a log" > run.sh
  else
    echo "time mpirun -np $procs ./sord | tee -a log" > run.sh
  fi
fi

;;

esac

chmod u+x *.sh

#------------------------------------------------------------------------------#


