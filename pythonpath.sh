# To add this directory to the Python path:
#     source pythonpath.py

dir="$( dirname $PWD )"

echo "Adding to Python path: $dir"
echo "To make permanent, add the following to your .bashrc or .profile:"

if [ -z "$PYTHONPATH" -o "$1" == "-f" ]; then
    export PYTHONPATH="$dir"
    echo "export PYTHONPATH=$dir"
else
    export PYTHONPATH="$dir:$PYTHONPATH"
    echo "export PYTHONPATH=$dir:\$PYTHONPATH"
fi

