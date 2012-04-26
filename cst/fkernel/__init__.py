"""
Frechet kernel computation
"""
from ..util import launch

def _build(optimize=None):
    """
    Build code
    """
    import os, shlex
    from .. import util
    cf = util.configure()[0]
    if not optimize:
        optimize = cf.optimize
    mode = cf.mode
    if not mode:
        mode = 'm'
    source = 'signal.f90', 'ker_utils.f90', 'cpt_ker.f90'
    new = False
    cwd = os.getcwd()
    path = os.path.dirname(__file__)
    bld = os.path.join(path, '..', 'build') + os.sep
    os.chdir(path)
    if not os.path.isdir(bld):
        os.mkdir(bld)
    if 'm' in mode and cf.fortran_mpi:
        for opt in optimize:
            object_ = bld + 'cpt_ker-m' + opt
            compiler = (
                [cf.fortran_mpi] +
                shlex.split(cf.fortran_flags['f']) +
                shlex.split(cf.fortran_flags[opt]) +
                ['-o']
            )
            new |= util.make(compiler, object_, source)
    #if new:
    #    cst._archive()
    os.chdir(cwd)
    return

def stage(inputs={}, **kwargs):
    """
    Stage job
    """
    import os, shutil
    from .. import util

    print('Frechet kernel setup')

    # update inputs
    inputs = inputs.copy()
    inputs.update(kwargs)

    # configure
    job, inputs = util.configure(**inputs)
    if inputs:
        raise Exception('Unknown parameter: %s' % inputs)
    if not job.mode:
        job.mode = 'm'
    if job.mode != 'm':
        raise Exception('Must be MPI')
    job.command = os.path.join('.', 'cpt_ker-' + job.mode + job.optimize + ' in/input_files')
    job = util.prepare(job)

    # build
    if not job.prepare:
        return job
    _build(job.mode, job.optimize)

    # create run directory
    util.skeleton(job)
    shutil.copytree('tmp', os.path.join(job.rundir, 'in'))
    f = os.path.join(job.rundir, 'out')
    os.mkdir(f)

    return job

