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

def configure(**kwargs):
    from .. import util
    job = util.configure(**kwargs)
    job.update(dict(
        nsample = 0,
        minutes = 20,
        version = '4.0',
        code = 'cvms',
        name = 'cvms',
        stagein = ['hold/'],
        file_lon = 'hold/lon.bin',
        file_lat = 'hold/lat.bin',
        file_dep = 'hold/dep.bin',
        file_rho = 'hold/rho.bin',
        file_vp = 'hold/vp.bin',
        file_vs = 'hold/vs.bin',
    ))
    if job.machine.startswith('alcf_bg'):
        job.build_fflags = '-O3 -qfixed -qsuppress=cmpmsg'
    elif job.machine == 'tacc_ranger':
        job.build_fflags = '-O3 -warn -std08'
    elif job.machine == 'nics_kraken':
        job.build_fflags = '-fast -Mdclchk'
    else:
        job.build_fflags = '-O3 -Wall'
    return job

def build(**kwargs):
    """
    Build CVM-S code.
    """
    import os, urllib, tarfile, shutil, subprocess

    # configure
    job = configure(options=[], **kwargs)
    assert job.version in ('2.2', '3.0', '4.0')
    ver = 'cvms-' + job.version

    # build directory
    path = os.path.dirname(__file__)
    cwd = os.getcwd()
    d = os.path.join(path, 'build')
    if not os.path.exists(d):
        os.mkdir(d)
    os.chdir(d)

    # download source code
    u = 'http://earth.usc.edu/~gely/cvm-data/%s.tgz' % ver
    f = os.path.basename(u)
    if not os.path.exists(f):
        print('Downloading %s' % u)
        urllib.urlretrieve(u, f)

    # build
    if not os.path.exists(ver):
        os.mkdir(ver)
        os.chdir(ver)
        f = os.path.join(path, 'build', f)
        tarfile.open(f, 'r:gz').extractall()
        f = os.path.join(path, ver + '.patch')
        subprocess.check_call(['patch', '-p1', '-i', f])
        if job.build_mpi:
            mode = 'mpi'
        else:
            mode = 'bin'
        f = os.path.join(path, 'io%s.f' % mode)
        shutil.copy2(f, '.')
        m = os.path.join(path, 'Makefile.in')
        m = open(m).read().format(mode=mode, **job)
        open('Makefile', 'w').write(m)
        subprocess.check_call(['make'])

    # finished
    os.chdir(cwd)
    return

def stage(nsample, **kwargs):
    """
    Stage job
    """
    import os, sys, re, shutil
    from .. import util

    print('CVM-S setup')

    # configure
    job = configure(**kwargs)
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
    minproc = int(nsample / n)
    if nsample % n != 0:
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

