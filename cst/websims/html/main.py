head = """\
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
    <title>%(title)s</title>
    <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
    <meta name="robots" content="noindex">
    <link rel="icon" href="%(baseurl)s/static/favicon.ico" type="image/x-icon">
    <link rel="stylesheet" href="%(baseurl)s/static/style.css" type="text/css">
</head>
<body>
<h1 class="title"><a href="%(baseurl)s">WebSims</a></h1>
<ul class="navbar">
    <li><a href="%(baseurl)s">Catalog</a></li>
    <li><a href="%(baseurl)s/repo/">Files</a></li>
    <li><a href="%(baseurl)s/about">About</a></li>
    <li><form class="navbar" action="%(baseurl)s">
        <input type="text" size="30" name="search" value="%(search)s">
        <input type="submit" value="Search">
    </form></li>
</ul>
"""

foot = """\
</body>
</html>
"""

section = """\
<h3>%(title)s</h3>
%(content)s
"""

