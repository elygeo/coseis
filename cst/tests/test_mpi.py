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

def test_mpi():
    """
    Basic MPI test
    """
    import os, shlex, subprocess
    import cst
    job = cst.util.skeleton(
        name = 'mpi',
        command = './test',
        nproc = 2,
        force = True,
        options = [],
    )
    f = os.path.join(job.rundir, 'test')
    open(f + '.f90', 'w').write(code)
    cmd = (
        [job.fortran_mpi] +
        shlex.split(job.fortran_flags['f']) +
        shlex.split(job.fortran_flags['O']) +
        ['-o', f, f + '.f90'] 
    )
    subprocess.check_call(cmd)
    cst.util.launch(job, run='exec')

# continue if command line
if __name__ == '__main__':
    test_mpi()

