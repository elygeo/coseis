"""
CST: Computational Seismology Tools
"""
import os
import sys

while '' in sys.path:
    sys.path.remove('')

home = os.path.dirname(__file__)
home = os.path.realpath(home)
home = os.path.dirname(home) + os.sep
repo = os.path.join(home, 'Repo') + os.sep

def __main__():
    print(12)
