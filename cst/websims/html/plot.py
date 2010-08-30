head = """\
"""

plot2d = """
    <img class="plot" src="%(baseurl)s/image/%(path)s%(ext)s?ids=%(id)s&amp;t=%(t)s&amp;decimate=%(decimate)s" alt="plotting..."><br>
"""

plot1d = """\
    <img class="plot" src="%(baseurl)s/image/plot%(ext)s?ids=%(ids)s&amp;x=%(x)s&amp;lowpass=%(lowpass)s" alt="plotting...">
"""

click2d = """\
<a href="%(baseurl)s/click2d/%(ids)s">
    <img class="plot" src="%(baseurl)s/image/%(path)s%(ext)s?ids=%(id)s&amp;t=%(t)s&amp;decimate=%(decimate)s" alt="plotting..." ismap>
</a>
"""

click1d = """\
<a href="%(baseurl)s/click1d/%(ids)s">
    <img class="plot" src="%(baseurl)s/image/plot%(ext)s?ids=%(ids)s&amp;x=%(x)s&amp;lowpass=%(lowpass)s" alt="plotting..." ismap>
</a>
"""

foot = """\
"""

