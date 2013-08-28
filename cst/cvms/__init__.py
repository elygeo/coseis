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
    import os, json
    from .. import util
    job = util.configure(**kwargs)
    f = os.path.dirname(__file__)
    f = os.path.join(f, 'conf.json')
    job.update(json.load(open(f)))
    for k, d in job['host_opts':]
        if k in job['machine']:
            for k, v in d.items():
                job[k] = v
    job['command'] = os.path.join('.', 'cvms.x')
    assert job.version in ('2.2', '3.0', '4.0')
    return job

def download(version):
    """
    Download CVMS data
    """
    import os, urllib
    from .. import repo
    u = 'http://earth.usc.edu/~gely/cvm-data/%s.tgz' % version
    f = os.path.basename(u)
    f = os.path.join(repo, f)
    if not os.path.exists(f):
        print('Downloading %s' % u)
        urllib.urlretrieve(u, f)
    return f

def make(job=None, **kwargs):
    """
    Build CVM-S code.
    """
    import os, tarfile, shutil, subprocess

    # configure
    if job == None:
        job = configure(options=[], **kwargs)
    ver = 'cvms-' + job.version
    tar = download(ver)

    # build directory
    cwd = os.getcwd()
    src = os.path.dirname(__file__) + os.sep
    bld = os.path.join(src, 'build', ver)

    # unpack and patch files
    if os.path.exists(bld):
        os.chdir(bld)
    else:
        os.makedirs(bld)
        os.chdir(bld)
        tarfile.open(tar, 'r:gz').extractall()
        shutil.copy2(src + ver + '.patch', '.')
        shutil.copy2(src + 'iobin.f', '.')
        shutil.copy2(src + 'iompi.f', '.')

    # build
    f = open(src + 'in.h.in').read().format(max_samples=job['max_samples'])
    open('in.h', 'w').write(f)
    f = open(src + 'Makefile.in').read().format(machine=job['machine'], version=ver)
    open('Makefile', 'w').write(f)
    subprocess.check_call(['make', '-j', '2'])

    # finished
    os.chdir(cwd)
    return

def stage(**kwargs):
    """
    Stage job
    """
    import os, sys, shutil
    from .. import util

    # configure
    print('CVM-S setup')
    job = configure(**kwargs)
    job = util.prepare(job)
    ver = 'cvms-' + job.version

    # check memory usage
    n = (job.nsample - 1) // job.nproc + 1
    p = (job.nsample - 1) // job.max_samples + 1
    if p > job.nproc:
        sys.exit('nsample = %s requires nproc >= %s or max_samples >= %s' %
            (job.nsample, p, n))

    # build code
    make(job)

    # create run directory
    FIXME
    if os.path.exists(job.rundir):
        f = os.path.join(job.rundir, 'cvms.x')
        if not os.path.exists(f):
            raise Exception('%s exists' % job.rundir)
    else:
        d = os.path.dirname(__file__)
        f = os.path.join(d, 'build', ver)
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
    os.unlink(path + job.name + '.conf.json')
    return np.array(out)

