"""
Computational Seismology Tools
"""

# data repository
import os
repo = os.path.dirname(__file__)
repo = os.path.join(repo, 'repo') + os.sep
if not os.path.exists(repo):
    f = os.path.dirname(__file__)
    f = os.path.join(f, '..', '..', 'Repository')
    if os.path.exists(f):
        os.symlink('../../Repository', repo)
    else:
        os.mkdir(repo)
del(os)

