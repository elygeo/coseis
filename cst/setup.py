import os
import sys
import site
from . import home


def set_path(force=False):
    home0 = home
    d = site.USER_SITE + os.sep
    f = d + __package__ + '.pth'
    if os.path.exists(f):
        home1 = open(f).read().strip()
        if home != home1:
            if force:
                print('Updating path file')
                open(f, 'w').write(home)
            else:
                print('Path file exists, use -f to force update')
                home0 = home1
        else:
            print('Path file is up to date')
    else:
        print('Creating path file')
        if not os.path.exists(d):
            os.makedirs(d)
        open(f, 'w').write(home)
    print(f)
    print(home0)


if __name__ == '__main__':
    set_path('-f' in sys.argv[1:])
