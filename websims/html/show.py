head = """\
<h2><a class="h2" href="%(baseurl)s?ids=%(ids)s">%(title)s</a></h2>
%(notes)s
"""

foot = """\
"""

form1d = """\
<form action="%(baseurl)s">
<div>
    <input type="hidden" name="ids" value="%(ids)s">
    %(axes)s=
    <input type="text" size="12" name="x" value="%(x)s"> (%(xlim)s),
    Lowpass frequency=
    <input type="text" size="6" name="lowpass" value="%(lowpass)s"> (%(flim)s)
    <input type="submit" value="Plot time history">
</div>
</form>
"""

form2d = """\
<form action="%(baseurl)s">
    <div>
    <input type="hidden" name="ids" value="%(ids)s">
    Time=
    <input type="text" size="6" name="t" value="%(t)s"> (%(tlim)s),
    Decimation interval=
    <input type="text" size="1" name="decimate" value="%(decimate)s">
    <input type="submit" value="Plot snapshot">
    </div>
</form>
"""

plot2d = """
<div>
    <img src="%(baseurl)s/image/%(path)s%(ext)s?ids=%(id)s&amp;t=%(t)s&amp;decimate=%(decimate)s" alt="plotting..."><br>
</div>
"""

plot1d = """\
<div>
    <img src="%(baseurl)s/image/plot%(ext)s?ids=%(ids)s&amp;x=%(x)s&amp;lowpass=%(lowpass)s" alt="plotting...">
</div>
"""

click2d = """\
<div>
<a href="%(baseurl)s/click2d/%(ids)s">
    <img src="%(baseurl)s/image/%(path)s%(ext)s?ids=%(id)s&amp;t=%(t)s&amp;decimate=%(decimate)s" alt="plotting..." ismap>
</a>
</div>
"""

click1d = """\
<div>
<a href="%(baseurl)s/click1d/%(ids)s">
    <img src="%(baseurl)s/image/plot%(ext)s?ids=%(ids)s&amp;x=%(x)s&amp;lowpass=%(lowpass)s" alt="plotting..." ismap>
</a>
</div>
"""

download_head = """\
<div>
    Download source data:<br>
</div>
<div>
"""

download_item = """\
    %(name)s, n=%(n)s:
    <a href="%(baseurl)s/download/%(path)s.f32?ids=%(id)s&amp;j=%(j)s">%(root)s.f32</a>,
    <a href="%(baseurl)s/download/%(path)s.txt?ids=%(id)s&amp;j=%(j)s">%(root)s.txt</a>,
    <a href="%(baseurl)s/download/%(path)s.gz?ids=%(id)s&amp;j=%(j)s">%(root)s.gz</a>
    <br>
"""

download_foot = """\
</div>
<div>
    File types:<br>
</div>
<div>
    f32: 32-bit little-endian floating-point binary.<br>
    txt: ASCII text.<br>
    gz: Gzipped ASCII text.<br>
</div>
"""

