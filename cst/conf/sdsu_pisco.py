"""
SDSU Pisco

ssh -fNL localhost:8022:pisco.sdsu.edu:22 sciences.sdsu.edu
ssh -p 8022 localhost

MPICH instead of OpenMPI:
export PATH="/opt/mpich2/gnu/bin:${PATH}"
"""

core_range = range(1, 9)
maxram = 32768

