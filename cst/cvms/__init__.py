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

def build(job=None, version='4.0', **kwargs):
    """
    Build CVM-S code.
    """
    import os, shlex, urllib, tarfile, subprocess
    from .. import util, data

    # configure
    if job==None:
        job = util.configure(options=[], **kwargs)
    assert version in ('2.2', '3.0', '4.0')
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
    bld = os.path.join(path, 'build', ver)
    cwd = os.getcwd()
    if os.path.isdir(bld):
        os.chdir(bld)
    else:
        os.makedirs(bld)
        os.chdir(bld)
        f = tarfile.open(tarball, 'r:gz')
        f.extractall(bld)
        f = os.path.join(path, ver + '.patch')
        subprocess.check_call(['patch', '-p1', '-i', f])
        if job.build_mpi:
            mode = 'mpi'
        else:
            mode = 'bin'
        m = os.path.join('..', '..', 'Makefile.in')
        m = open(m).read()
        m = m.format(version=version, mode=mode, **job)
        open('Makefile', 'w').write(m)

    # make
    subprocess.check_call(['make'])

    # finished
    os.chdir(cwd)
    return

def stage(**kwargs):
    """
    Stage job
    """
    import os, sys, re, shutil
    from .. import util

    print('CVM-S setup')

    # configure
    job = util.configure(code='cvms', name='cvms', **kwargs)
    job.command = os.path.join('.', 'cvms.x')
    job = util.prepare(job)
    ver = 'cvms-' + job.version

    # build
    if not job.prepare:
        return job
    build(job)

    # check minimum processors needed for compiled memory size
    path = os.path.dirname(__file__)
    f = os.path.join(path, 'build', ver, 'in.h')
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
        f = os.path.join(path, 'build', ver)
        shutil.copytree(f, job.rundir)
    else:
        for f in [
            job.file_lon, job.file_lat, job.file_dep,
            job.file_rho, job.file_vp, job.file_vs,
        ] + job.stagein:
            ff = os.path.join(job.rundir, f)
            if os.path.isdir(ff):
                shutil.rmtree(ff)
            elif os.path.exists(ff):
                os.remove(ff)

    # process machine templates
    util.skeleton(job)

    # save input file and configuration
    f = os.path.join(job.rundir, 'cvms-input')
    open(f, 'w').write(input_template.format(**job))
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

