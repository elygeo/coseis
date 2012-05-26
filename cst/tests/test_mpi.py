def test_mpi():
    """
    Basic MPI test
    """
    import os, shlex, shutil
    import cst
    src = os.path.join(os.path.dirname(__file__), 'test_mpi.f90'),
    job = cst.util.skeleton(command='./test_mpi', nproc=3)
    obj = os.path.join(job.rundir, 'test_mpi')
    cmd = (
        [job.fortran_mpi] +
        shlex.split(job.fortran_flags['f']) +
        shlex.split(job.fortran_flags['O']) +
        ['-o'] 
    )
    cst.util.make(cmd, obj, src)
    cst.util.launch(job)
    shutil.rmtree(job.rundir)

# continue if command line
if __name__ == '__main__':
    test_mpi()

