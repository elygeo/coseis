head = """\
<h3><a href="%(baseurl)s/app?ids=%(ids)s">%(title)s</a> / %(subtitle)s</h3>
%(notes)s
"""

form1d = """\
<form class="t" action="%(baseurl)s/app">
    <fieldset>
    <legend>Time history</legend>
    <input type="hidden" name="ids" value="%(ids)s">
    <label for="x">%(axes)s (%(xlim)s):</label>
    <input id="x" type="text" size="12" name="x" value="%(x)s"><br>
    <label for="t">Lowpass frequency (%(flim)s):</label>
    <input id="t" type="text" size="12" name="lowpass" value="%(lowpass)s"><br>
    <input type="submit" value="Plot">
    </fieldset>
</form>
"""

form2d = """\
<form class="x" action="%(baseurl)s/app">
    <fieldset>
    <legend>Snapshot</legend>
    <input type="hidden" name="ids" value="%(ids)s">
    <label for="t">Time (%(tlim)s):</label>
    <input id="t" type="text" size="12" name="t" value="%(t)s"><br>
    <label for="x">Decimation interval:</label>
    <input id="x" type="text" size="12" name="decimate" value="%(decimate)s"><br>
    <input type="submit" value="Plot">
    </fieldset>
</form>
"""

foot = """\
<div style="clear: both"></div>
"""

