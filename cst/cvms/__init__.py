"""
SCEC Community Velocity Model - Magistrale version

http://www.data.scec.org/3Dvelocity/
"""

input_template = """\
{nsample}
{iodir}/{file_lon}
{iodir}/{file_lat}
{iodir}/{file_dep}
{iodir}/{file_rho}
{iodir}/{file_vp}
{iodir}/{file_vs}
"""

def configure(**kwargs):
    from .. import util, conf
    from . import conf as conf_local
    job = util.configure(conf.default, conf.site, conf_local, **kwargs)
    for k, d in job.host_opts_cvms.items():
        if k in job.machine:
            for k, v in d.items():
                job[k] = v
    return job

def build(job=None, **kwargs):
    """
    Build CVM-S code.
    """
    import os, urllib, tarfile, shutil, subprocess

    # configure
    if job == None:
        job = configure(options=[], **kwargs)
    assert job.version in ('2.2', '3.0', '4.0')
    ver = 'cvms-' + job.version
    if job.build_mpi:
        mode = 'mpi'
    else:
        mode = 'bin'

    # build directory
    cwd = os.getcwd()
    d = os.path.dirname(__file__)
    d = os.path.join(d, 'build')
    if not os.path.exists(d):
        os.mkdir(d)
    os.chdir(d)

    # download source code
    u = 'http://earth.usc.edu/~gely/cvm-data/%s.tgz' % ver
    f = os.path.basename(u)
    if not os.path.exists(f):
        print('Downloading %s' % u)
        urllib.urlretrieve(u, f)

    # unpack and patch files
    if os.path.exists(ver):
        os.chdir(ver)
    else:
        os.mkdir(ver)
        os.chdir(ver)
        f = os.path.join('..', f)
        tarfile.open(f, 'r:gz').extractall()
        f = os.path.join('..', '..', ver + '.patch')
        subprocess.check_call(['patch', '-p1', '-i', f])
        f = os.path.join('..', '..', 'io%s.f' % mode)
        shutil.copy2(f, '.')

    # build
    m = os.path.join('..', '..', 'Makefile.in')
    m = open(m).read().format(mode=mode, **job)
    open('Makefile', 'w').write(m)
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

    # configure and build
    print('CVM-S setup')
    job = configure(**kwargs)
    job.command = os.path.join('.', 'cvms.x')
    job = util.prepare(job)
    build(job)
    ver = 'cvms-' + job.version

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
    if os.path.exists(job.rundir):
        f = os.path.join(job.rundir, 'cvms.x')
        if not os.path.exists(f):
            raise Exception('%s exists' % job.rundir)
    else:
        f = os.path.join(path, 'build', ver)
        shutil.copytree(f, job.rundir)

    # clean-up old input files
    for f in job.file_rho, job.file_vp, job.file_vs:
        f = os.path.join(job.iodir, f)
        if os.path.exists(f):
            os.remove(f)

    # create input files
    util.skeleton(job)
    f = os.path.join(job.rundir, 'cvms-input')
    open(f, 'w').write(input_template.format(**job))

    return job

def launch(job=None, **kwargs):
    """
    Launch or submit job.
    """
    from .. import util

    if job is None:
        job = stage(**kwargs)
    else:
        for k in kwargs:
            job[k] = kwargs[k]
    job = util.launch(job)
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
    job = stage(nsample=dep.size, iodir='.', **kwargs)
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
    os.unlink(path + job.file_lon)
    os.unlink(path + job.file_lat)
    os.unlink(path + job.file_dep)
    os.unlink(path + job.file_rho)
    os.unlink(path + job.file_vp)
    os.unlink(path + job.file_vs)
    os.unlink(path + job.name + '.conf.py')
    return np.array(out)

