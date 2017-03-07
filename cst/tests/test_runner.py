"""
Run tests suite
"""
import os
import shutil
from . import hello
from .. import job, sord

hello.make()
sord.make()

cwd = os.getcwd()
d = os.path.join('run', 'test_suite')
os.makedirs(d)
shutil.copy2('test_suite.py', d)
os.chdir(d)
job.launch(
    mode='script',
    execute='python test_suite.py',
    nproc=6,
    minutes=30,
)
os.chdir(cwd)
