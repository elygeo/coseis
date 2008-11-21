#!/bin/bash -e

#@environment = COPY_ALL;\\
#AIXTHREAD_SCOPE=S;\\
#MP_ADAPTER_USE=dedicated;\\
#MP_CPU_USE=unique;\\
#MP_CSS_INTERRUPT=no;\\
#MP_EAGER_LIMIT=16384;\\
#MP_EUIDEVELOP=min;\\
#MP_LABELIO=yes;\\
#MP_POLLING_INTERVAL=100000;\\
#MP_PULSE=0;\\
#MP_SHARED_MEMORY=yes;\\
#MP_SINGLE_THREAD=no;\\
#RT_GRQ=ON;\\
#SPINLOOPTIME=0;\\
#YIELDLOOPTIME=0;
#@ job_name = %(name)s
#@ initialdir = %(rundir)s
#@ node = %(nodes)s
#@ tasks_per_node = %(ppn)s
#@ wall_clock_limit = %(walltime)s
#@ resources = ConsumableCpus(1) ConsumableMemory(%(ram)smb)
#@ notification = always
#@ notify_user = %(email)s
#@ job_type = parallel
#@ class = normal
#@ node_usage = not_shared
#@ network.MPI = sn_all, shared, US
#@ output = stdout
#@ error = stderr
#@ queue

cd %(rundir)r

echo "$( date ): %(name)s started" >> log
%(pre)s
poe hpmcount -nao prof/hpm %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

