"""
General utilities
"""
import os, sys, re
import numpy as np

class namespace:
    """
    Namespace with object attributes initialized from a dict.
    """
    def __init__(self, d):
        self.__dict__.update(d)


def prune(d, pattern=None, types=None):
    """
    Delete dictionary keys with specified name pattern or types

    Parameters
    ----------
        d : dict of parameters
        pattern : regular expression of parameter names to prune
            default = '(^_)|(_$)|(^.$)|(^..$)'
        types : list of parameters types to keep
            default = Numpy types + [NoneType, bool, str, int, lone, float, tuple, list, dict]
            Functions, classes, and modules are pruned by default.

    >>> prune({'aa': 0, 'aa_': 0, '_aa': 0, 'a_a': 0, 'b_b': prune})
    {'a_a': 0}
    """
    if pattern is None:
        pattern = '(^_)|(_$)|(^.$)|(^..$)'

    if types is None:
        types = set(
            np.typeDict.values() +
            [type(None), bool, str, unicode, int, long, float, tuple, list, dict]
        )
    grep = re.compile(pattern)
    for k in d.keys():
        if grep.search(k) or type(d[k]) not in types:
            del(d[k])
    return d


def open_excl(filename, *args):
    """
    Thread-safe exclusive file open. Silent return if exists.
    """
    if os.path.exists(filename):
        return
    try:
        os.mkdir(filename + '.lock')
    except:
        return
    fh = open(filename, *args)
    os.rmdir(filename + '.lock')
    return fh


def save(fd, d, expand=None, keep=None, header='', prune_pattern=None, prune_types=None):
    """
    Write variables from a dict into a Python source file.
    """
    if type(d) is not dict:
        d = d.__dict__
    if expand is None:
        expand = []
    prune(d, prune_pattern, prune_types)
    out = header
    for k in sorted(d):
        if k not in expand and (keep is None or k in keep):
            out += '%s = %r\n' % (k, d[k])
    for k in expand:
        if k in d:
            if type(d[k]) is tuple:
                out += k + ' = (\n'
                for item in d[k]:
                    out += '    %r,\n' % (item,)
                out += ')\n'
            elif type(d[k]) is list:
                out += k + ' = [\n'
                for item in d[k]:
                    out += '    %r,\n' % (item,)
                out += ']\n'
            elif type(d[k]) is dict:
                out += k + ' = {\n'
                for item in sorted(d[k]):
                    out += '    %r: %r,\n' % (item, d[k][item])
                out += '}\n'
            else:
                sys.exit('Cannot expand %s type %s' % (k, type(d[k])))
    if fd is not None:
        if type(fd) is not file:
            fd = open(os.path.expanduser(fd), 'w')
        fd.write(out)
    return out


def load(fd, d=None, prune_pattern=None, prune_types=None):
    """
    Load variables from Python source files.
    """
    if type(fd) is not file:
        fd = open(os.path.expanduser(fd))
    if d is None:
        d = {}
    exec fd in d
    prune(d, prune_pattern, prune_types)
    return namespace(d)

