#!/bin/bash -e
prefix="${SCRATCHDIR}/local"
echo "Statically linked Python for Compute Node Linux on NICS Kraken"
echo -n "Install in ${prefix}? [y/N]: "
read confirm
[ "$confirm" = "y" ]

# virtualenv yt Python version
cd "${prefix}"
module load yt
url="http://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.7.1.2.tar.gz"
tag=$( basename "$url" .tar.gz )
curl -L "${url}" | tar zx
python "${tag}/virtualenv.py" python
. python/bin/activate

# Python packages
pip install pyproj
pip install GitPython
pip install readline
pip install nose
pip install docutils
pip install PIL
#pip install scipy
#pip install ipython

