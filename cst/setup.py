import os
import site
from . import home


def set_path():
    d = site.USER_SITE + os.sep
    f = d + __package__ + '.pth'
    print('Package home: ' + home)
    if os.path.exists(f):
        home1 = open(f).read()
        print('Path file: ' + f)
        if home != home1:
            print('with different path ' + home1)
    else:
        if not os.path.exists(d):
            print('Creating ' + d)
            os.makedirs(d)
        print('Creating path file ' + f)
        open(f, 'w').write(home)


if __name__ == '__main__':
    set_path()
