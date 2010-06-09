head = """\
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
    <title>%(title)s</title>
    <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
    <link rel="icon" href="%(baseurl)s/static/favicon.ico" type="image/x-icon">
    <link rel="stylesheet" href="%(baseurl)s/static/style.css" type="text/css">
</head>
<body>
<h1><a class="h1" href="%(baseurl)s">WebSims</a></h1>
<form action="%(baseurl)s">
<div class="search">
    <a class="h1" href="%(baseurl)s/about">Version 2.0</a>&nbsp;&nbsp;&nbsp;
    <input type="text" size="30" name="search" value="%(search)s">
    <input type="submit" value="Catalog search">
</div>
</form>
"""

foot = """\
<h3>
    <a class="h3" href="%(baseurl)s/about">About WebSims</a> |
    <a class="h3" href="%(baseurl)s/static/websims.tgz">Download source code</a>
</h3>
</body>
</html>
"""

about = """\
<h2>About</h2>
<div>
WebSims is a simple tool for cataloging, exploring, comparing and disseminating
four-dimensional results of large numerical simulations.  Users may extract
time histories or two-dimensional slices via a clickable interface or by
specifying precise coordinates.  Extractions are plotted to the screen and may
optionally be downloaded to local disk.  Time histories may be low-pass
filtered, and multiple simulations may be overlayed for comparison.  Metadata
is stored with each simulation in the form of a Python module.  A well defined
URL scheme for specifying extractions allows the web interface to be bypassed,
allowing for batch scripting of both plotting and download tasks.  This version
of WebSims replaces a previous PHP implementation.  It is written in
<a href="http://www.python.org">Python</a>
using the
<a href="http://numpy.scipy.org">NumPy</a>,
<a href="http://www.scipy.org">SciPy</a>
and
<a href="http://matplotlib.sourceforge.net">Matplotlib</a>
modules, which provide MATLAB-like processing and visualization environment.
The web pages are served by a slightly modified version of
<a href="http://webpy.org">web.py</a>,
a simple web application framework somewhat like Google App Engine.  The source
code is a rapidly changing and lightly documented, but you may download it from
the link at the bottom of the page footer.  WebSims is written by
<a href="http://earth.usc.edu/~gely/">Geoffrey Ely</a>
and released under the GPLv3.
</div>
"""
