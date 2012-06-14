#!/usr/bin/env python

code = """
program main
use mpi
integer :: e, i, n
call mpi_init(e)
call mpi_comm_rank(mpi_comm_world, i, e)
call mpi_comm_size(mpi_comm_world, n, e)
print *, 'Process ', i, ' of ', n
!call sleep(3)
call mpi_finalize(e)
end program
"""

def test(argv=[]):
    """
    Basic MPI test
    """
    import os, shlex, subprocess
    import cst
    job = cst.util.skeleton(
        run = 'exec',
        argv = argv,
        name = 'hello_mpi',
        nproc = 2,
        force = True,
        command = './test',
        minutes = 10,
    )
    f = os.path.join(job.rundir, 'test')
    open(f + '.f90', 'w').write(code)
    c = (
        [job.compiler_f] +
        shlex.split(job.compiler_opts['f']) +
        shlex.split(job.compiler_opts['O']) +
        ['-o', f, f + '.f90'] 
    )
    print(' '.join(c))
    subprocess.check_call(c)
    cst.util.launch(job)

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

