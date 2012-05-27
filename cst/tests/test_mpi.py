code = """
    program main
    use mpi
    integer :: e, i, n
    call mpi_init(e)
    call mpi_comm_rank(mpi_comm_world, i, e)
    call mpi_comm_size(mpi_comm_world, n, e)
    print *, 'Process ', i, ' of ', n
    call mpi_finalize(e)
    end program
"""

def test_mpi():
    """
    Basic MPI test
    """
    import os, shlex, shutil
    import cst
    job = cst.util.skeleton(command='./test', nproc=2, options=[])
    src = os.path.join(job.rundir, 'test.f90'),
    obj = os.path.join(job.rundir, 'test')
    cmd = (
        [job.fortran_mpi] +
        shlex.split(job.fortran_flags['f']) +
        shlex.split(job.fortran_flags['O']) +
        ['-o'] 
    )
    open(src[0], 'w').write(code)
    cst.util.make(cmd, obj, src)
    cst.util.launch(job, run='exec')
    shutil.rmtree(job.rundir)

# continue if command line
if __name__ == '__main__':
    test_mpi()

