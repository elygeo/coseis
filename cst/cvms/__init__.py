"""
SCEC Community Velocity Model - Magistrale version

http://www.data.scec.org/3Dvelocity/
"""
from ..util import launch

input_template = """\
{nsample}
{file_lon}
{file_lat}
{file_dep}
{file_rho}
{file_vp}
{file_vs}
"""

def _build(job=None):
    """
    Build CVM-S code.
    """
    import os, shlex, urllib, tarfile, subprocess
    from .. import util, data

    # configure
    if job==None:
        job = util.configure('cvms')[0]
    if not job.mode:
        job.mode = 'asm'
    assert job.version in ('2.2', '3.0', '4.0')
    ver = 'cvms-' + job.version

    # download source code
    url = 'http://earth.usc.edu/~gely/cvm-data/%s.tgz' % ver
    tarball = os.path.join(data.repo, os.path.basename(url))
    if not os.path.exists(tarball):
        if not os.path.exists(data.repo):
            os.makedirs(data.repo)
        print('Downloading %s' % url)
        urllib.urlretrieve(url, tarball)

    # build directory
    path = os.path.dirname(__file__)
    bld = os.path.join(path, '..', 'build', ver)
    cwd = os.getcwd()
    if not os.path.isdir(bld):
        os.makedirs(bld)
        os.chdir(bld)
        fh = tarfile.open(tarball, 'r:gz')
        fh.extractall(bld)
        f = os.path.join(path, ver + '.patch')
        subprocess.check_call(['patch', '-p1', '-i', f])
    os.chdir(bld)

    # compile ascii, binary, and MPI versions
    new = False
    if 'a' in job.mode:
        source = 'iotxt.f', 'version%s.f' % job.version
        for opt in job.optimize:
            compiler = [job.fortran_serial] + shlex.split(job.fortran_flags[opt]) + ['-o']
            object_ = 'cvms-a' + opt
            new |= util.make(compiler, object_, source)
    if 's' in job.mode:
        source = 'iobin.f', 'version%s.f' % job.version
        for opt in job.optimize:
            compiler = [job.fortran_serial] + shlex.split(job.fortran_flags[opt]) + ['-o']
            object_ = 'cvms-s' + opt
            new |= util.make(compiler, object_, source)
    if 'm' in job.mode and job.fortran_mpi:
        source = 'iompi.f', 'version%s.f' % job.version
        for opt in job.optimize:
            compiler = [job.fortran_mpi] + shlex.split(job.fortran_flags[opt]) + ['-o']
            object_ = 'cvms-m' + opt
            new |= util.make(compiler, object_, source)
    os.chdir(cwd)
    return

def stage(inputs={}, **kwargs):
    """
    Stage job
    """
    import os, sys, re, shutil
    from .. import util

    print('CVM-S setup')

    # update inputs
    inputs = inputs.copy()
    inputs.update(kwargs)

    # configure
    job, inputs = util.configure('cvms', **inputs)
    if inputs:
        sys.exit('Unknown parameter: %s' % inputs)
    if not job.mode:
        job.mode = 's'
        if job.nproc > 1:
            job.mode = 'm'
    job.command = os.path.join('.', 'cvms-' + job.mode + job.optimize)
    job = util.prepare(job)
    ver = 'cvms-' + job.version

    # build
    if not job.prepare:
        return job
    _build(job)

    # check minimum processors needed for compiled memory size
    path = os.path.dirname(__file__)
    f = os.path.join(path, '..', 'build', ver, 'in.h')
    string = open(f).read()
    pattern = 'ibig *= *([0-9]*)'
    n = int(re.search(pattern, string).groups()[0])
    minproc = int(job.nsample / n)
    if job.nsample % n != 0:
        minproc += 1
    if minproc > job.nproc:
        sys.exit('Need at lease %s processors for this mesh size' % minproc)

    # create run directory
    if job.force == True and os.path.isdir(job.rundir):
        shutil.rmtree(job.rundir)
    if not os.path.exists(job.rundir):
        f = os.path.join(path, '..', 'build', ver)
        shutil.copytree(f, job.rundir)
    else:
        for f in (
            job.file_lon, job.file_lat, job.file_dep,
            job.file_rho, job.file_vp, job.file_vs,
        ) + job.stagein:
            ff = os.path.join(job.rundir, f)
            if os.path.isdir(ff):
                shutil.rmtree(ff)
            elif os.path.exists(ff):
                os.remove(ff)

    # process machine templates
    util.skeleton(job, stagein=job.stagein, new=False)

    # save input file and configuration
    f = os.path.join(job.rundir, 'cvms-input')
    open(f, 'w').write(input_template.format(**job.__dict__))
    f = os.path.join(job.rundir, 'conf.py')
    util.save(f, job.__dict__)
    return job

def extract(lon, lat, dep, prop=['rho', 'vp', 'vs'], **kwargs):
    """
    Simple CVM-S extraction

    Parameters
    ----------
    lon, lat, dep: Coordinate arrays
    prop: 'rho', 'vp', or 'vs'
    nproc: Optional, number of processes
    rundir: Optional, job staging directory

    Returns
    -------
    rho, vp, vs: Material arrays
    """
    import os
    import numpy as np
    lon = np.asarray(lon, 'f')
    lat = np.asarray(lat, 'f')
    dep = np.asarray(dep, 'f')
    shape = dep.shape
    job = stage(nsample=dep.size, **kwargs)
    path = job.rundir + os.sep
    lon.tofile(path + job.file_lon)
    lat.tofile(path + job.file_lat)
    dep.tofile(path + job.file_dep)
    del(lon, lat, dep)
    launch(job, run='exec')
    out = []
    if type(prop) not in [list, tuple]:
        prop = [prop]
    for v in prop:
        f = {'rho': job.file_rho, 'vp': job.file_vp, 'vs': job.file_vs}[v]
        out += [np.fromfile(path + f, 'f').reshape(shape)]
    return np.array(out)

