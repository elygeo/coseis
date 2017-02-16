import os
import site
from . import home
print(__package__)
print(home)
asdf


def set_path():
    d = site.USER_SITE + os.sep
    f = d + __package__ + '.pth'
    if not os.path.exists(f):
        if not os.path.exists(d):
            print('Creating ' + d)
            os.makedirs(d)
        print('Adding to sys.path: ' + home)
        open(f, 'w').write(home)


if __name__ == '__main__':
    set_path()
