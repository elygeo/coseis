head = """\
"""

plot2d = """
    <img class="plot" src="%(baseurl)s/app/image/%(path)s%(ext)s?ids=%(id)s&amp;t=%(t)s&amp;decimate=%(decimate)s" alt="plotting..."><br>
"""

plot2d_static = """
    <img class="plot" src="%(path)s%(ext)s" alt="plot"><br>
"""

plot1d = """\
    <img class="plot" src="%(baseurl)s/app/image/plot%(ext)s?ids=%(ids)s&amp;x=%(x)s&amp;lowpass=%(lowpass)s" alt="plotting...">
"""

click2d = """\
<a href="%(baseurl)s/app/click2d/%(ids)s">
    <img class="plot" src="%(baseurl)s/app/image/%(path)s%(ext)s?ids=%(id)s&amp;t=%(t)s&amp;decimate=%(decimate)s" alt="plotting..." ismap>
</a>
"""

click2d_static = """\
<a href="%(baseurl)s/app/click2d/%(ids)s">
    <img class="plot" src="%(path)s%(ext)s" alt="plot" ismap><br>
</a>
"""

click1d = """\
<a href="%(baseurl)s/app/click1d/%(ids)s">
    <img class="plot" src="%(baseurl)s/app/image/plot%(ext)s?ids=%(ids)s&amp;x=%(x)s&amp;lowpass=%(lowpass)s" alt="plotting..." ismap>
</a>
"""

foot = """\
"""

