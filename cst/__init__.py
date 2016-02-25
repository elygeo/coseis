"""
CST: Computational Seismology Tools
"""
import sys
while '' in sys.path:
    sys.path.remove('')
import os

home = os.path.dirname(__file__)
home = os.path.realpath(home)
home = os.path.dirname(home) + os.sep
repo = os.path.join(home, 'Repo') + os.sep
