"""
SCEC Community Velocity Model - Magistrale version

http://www.data.scec.org/3Dvelocity/
"""

input_template = """\
{nsample}
{file_lon}
{file_lat}
{file_dep}
{file_rho}
{file_vp}
{file_vs}
"""

def download(version):
    """
    Download CVMS data
    """
    import os, urllib, tarfile, cStringIO
    from .. import repo

    url = 'http://earth.usc.edu/~gely/cvm-data/CVMS-%s.tgz' % version
    path = os.path.join(repo, 'CVMS-%s' % version) + os.sep

    if not os.path.exists(path):
        os.makedirs(path + 'src')
        os.makedirs(path + 'data')
        print('Downloading %s' % url)
        tar = urllib.urlopen(url)
        tar = cStringIO.StringIO(tar.read())
        tar = tarfile.open(fileobj=tar, mode='r:gz')
        for t in tar:
            if os.path.splitext(t.name)[1] in ['.f', '.h', '.txt']:
                f = os.path.join(path, 'src', t.name)
            else:
                f = os.path.join(path, 'data', t.name)
            open(f, 'wb').write(tar.extractfile(t).read())
    return

def configure(force=False, **kwargs):
    import os, yaml
    from .. import util, repo

    # source directory
    cwd = os.getcwd()
    path = os.path.dirname(__file__)
    os.chdir(path)

    # configure
    cfg = yaml.load(open('defaults.yaml'))
    cfg = util.prepare(defaults=cfg, **kwargs)

    # machine specific options
    for k, d in cfg['machine_opts'].items():
        if k in cfg['machine']:
            for k, v in d.items():
                cfg[k] = v

    # download source code
    assert cfg['version'] in ['2.2', '3.0', '4.0']
    download(cfg['version'])

    # link source files
    p = os.path.join(repo, 'CVMS-%s' % cfg['version'], 'src')
    for f in os.listdir(p):
        if os.path.splitext(f)[1] in ['.f', '.h']:
            if not os.path.exists(f):
                g = os.path.join(p, f)
                os.link(g, f)

    # header file
    f = open('in.h.in').read()
    f = f.format(max_samples=cfg['max_samples'])
    open('in.h', 'w').write(f)

    # makefile
    if force or not os.path.exists('Makefile'):
        m = open('Makefile.in').read()
        m = m.format(
            version = cfg['version'],
            machine = cfg['machine'],
        )
        open('Makefile', 'w').write(m)

    # finished
    os.chdir(cwd)

    # run parameters
    cfg['name'] = 'cvms'
    cfg['executable'] = os.path.join('.', 'cvms.x')

    return cfg


def make(force=False, **kwargs):
    """
    Build the code
    """
    import os, subprocess
    cfg = configure(force, **kwargs)
    p = os.path.dirname(__file__) + os.sep
    if force:
        subprocess.check_call(['make', '-C', p, 'clean'])
    subprocess.check_call(['make', '-C', p, '-j', '2'])
    return cfg


def run(**kwargs):
    """
    Stage and launch job
    """
    import os, sys
    from .. import util, repo

    print('CVM-S')

    # configure and build code
    cfg = make(**kwargs)

    # check memory usage
    p = (cfg['nsample'] - 1) // cfg['max_samples'] + 1
    n = (cfg['nsample'] - 1) // cfg['nproc'] + 1
    if p > cfg['nproc']:
        sys.exit('nsample = %s requires nproc >= %s or max_samples >= %s' %
            (cfg['nsample'], p, n))

    # save source code
    util.archive('coseis.tgz')

    # link data files
    p = os.path.join(repo, 'CVMS-%s' % cfg['version'], 'data')
    for f in os.listdir(p):
        g = os.path.join(p, f)
        os.link(g, f)

    # link executable
    f = os.path.dirname(__file__)
    f = os.path.join(f, 'cvms.x')
    os.link(f, 'cvms.x')

    # create input file
    open('cvms.in', 'w').write(input_template.format(**cfg))

    # start job
    util.launch(cfg)

    return cfg

def extract(lon, lat, dep, prop=['rho', 'vp', 'vs'], **kwargs):
    """
    Simple CVM-S extraction

    Parameters
    ----------
    lon, lat, dep: Coordinate arrays
    prop: 'rho', 'vp', or 'vs'
    nproc: Optional, number of processes

    Returns
    -------
    rho, vp, vs: Material arrays
    """
    import os, shutil
    import numpy as np

    # sanitize arrays
    lon = np.asarray(lon, 'f')
    lat = np.asarray(lat, 'f')
    dep = np.asarray(dep, 'f')
    shape = dep.shape
    nsample = dep.size

    # configure job and build code
    cfg = make(**kwargs)

    # create temp directory
    cwd = os.getcwd()
    os.mkdir('cvms-tmp')
    os.chdir('cvms-tmp')

    # save input files
    job = configure(**kwargs)
    lon.tofile(cfg['file_lon'])
    lat.tofile(cfg['file_lat'])
    dep.tofile(cfg['file_dep'])
    del(lon, lat, dep)

    # run jon
    run(nsample=nsample, **kwargs)

    # read output
    out = []
    if type(prop) not in [list, tuple]:
        prop = [prop]
    for v in prop:
        f = {
            'rho': job['file_rho'],
            'vp':  job['file_vp'],
            'vs':  job['file_vs'],
        }[v]
        out += [np.fromfile(f, 'f').reshape(shape)]

    # clean up
    os.chdir(cwd)
    shutil.rmtree('cvms-tmp')

    return np.array(out)

