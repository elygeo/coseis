head = """\
<h3>Download source data</h3>
<ul>
"""

item = """\
<li>
%(name)s, n=%(n)s:
<a href="%(baseurl)s/download/%(path)s.f32?ids=%(id)s&amp;j=%(j)s">%(root)s.f32</a>,
<a href="%(baseurl)s/download/%(path)s.txt?ids=%(id)s&amp;j=%(j)s">%(root)s.txt</a>,
<a href="%(baseurl)s/download/%(path)s.gz?ids=%(id)s&amp;j=%(j)s">%(root)s.gz</a>
</li>
"""

foot = """\
</ul>
<h4>File types</h4>
<ul>
<li>f32: 32-bit little-endian floating-point binary.</li>
<li>txt: ASCII text.</li>
<li>gz: Gzipped ASCII text.</li>
</ul>
"""

