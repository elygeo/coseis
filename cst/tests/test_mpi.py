code = """
    program main
    use mpi
    integer :: e, i, n
    call mpi_init(e)
    call mpi_comm_rank(mpi_comm_world, i, e)
    call mpi_comm_size(mpi_comm_world, n, e)
    print *, 'Process ', i, ' of ', n
    call sleep(3)
    call mpi_finalize(e)
    end program
"""

def test_mpi(argv=[]):
    """
    Basic MPI test
    """
    import os, shlex, subprocess
    import cst
    job = cst.util.skeleton(
        run = 'exec',
        argv = argv,
        name = 'mpi',
        nproc = 2,
        force = True,
        command = './test',
    )
    f = os.path.join(job.rundir, 'test')
    open(f + '.f90', 'w').write(code)
    c = (
        [job.fortran_mpi] +
        shlex.split(job.fortran_flags['f']) +
        shlex.split(job.fortran_flags['t']) +
        ['-o', f, f + '.f90'] 
    )
    print(' '.join(c))
    subprocess.check_call(c)
    cst.util.launch(job)

# continue if command line
if __name__ == '__main__':
    import sys
    test_mpi(sys.argv[1:])

