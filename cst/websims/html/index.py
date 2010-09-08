head = """\
<form class="index" action="%(baseurl)s/app">
<table>
<tr>
    <th></th>
    <th>Title</th>
    <th>Author</th>
    <th>Date</th>
    <th></th>
    <th></th>
    <th></th>
</tr>
"""

item_solo = """\
<tr>
    <td></td>
    <td><a href="repo/%(id)s/%(index)s">%(title)s</a></td>
    <td>%(author)s</td>
    <td>%(rundate)s</td>
    <td><a href="repo/%(id)s/%(index)s">Plots</a></td>
    <td><a href="repo/%(id)s/">Files</a></td>
    <td><a href="repo/%(id)s/%(meta)s">Metadata</a></td>
</tr>
"""

item_grouped = """\
<tr>
    <td><input type="checkbox" name="ids" value="%(id)s"></td>
    <td><a href="repo/%(id)s/%(index)s">%(title)s</a></td>
    <td>%(author)s</td>
    <td>%(rundate)s</td>
    <td><a href="repo/%(id)s/%(index)s">Plots</a></td>
    <td><a href="repo/%(id)s/">Files</a></td>
    <td><a href="repo/%(id)s/%(meta)s">Metadata</a></td>
</tr>
"""

group_end = """\
<tr>
    <td colspan="7"><input type="submit" value="Compare"></td>
</tr>
"""

foot = """\
</table>
</form>
"""

