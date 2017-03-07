import os
import site
from . import home
print(__name__)


def set_path():
    d = site.USER_SITE + os.sep
    f = d + __package__ + '.pth'
    print(f)
    if not os.path.exists(f):
        if not os.path.exists(d):
            print('Creating ' + d)
            os.makedirs(d)
        print('Adding to sys.path: ' + home)
        open(f, 'w').write(home)


if __name__ == '__main__':
    set_path()
