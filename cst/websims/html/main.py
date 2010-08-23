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
    <a class="h3" href="%(baseurl)s/about">About WebSims</a>
</h3>
</body>
</html>
"""

