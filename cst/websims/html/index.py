head = """\
<form class="index" action="%(baseurl)s">
<table>
<tr>
    <th></th>
    <th>Title</th>
    <th>Author</th>
    <th>Date</th>
    <th>Metadata</th>
</tr>
"""

item_solo = """\
<tr>
    <td></td>
    <td><a href="?ids=%(id)s">%(title)s</a></td>
    <td>%(author)s</td>
    <td>%(rundate)s</td>
    <td><a href="%(meta)s">%(label)s</a></td>
</tr>
"""

item_grouped = """\
<tr>
    <td><input type="checkbox" name="ids" value="%(id)s"></td>
    <td><a href="?ids=%(id)s">%(title)s</a></td>
    <td>%(author)s</td>
    <td>%(rundate)s</td>
    <td><a href="%(meta)s">%(label)s</a></td>
</tr>
"""

group_end = """\
<tr>
    <td colspan="5"><input type="submit" value="Compare"></td>
</tr>
"""

foot = """\
</table>
</form>
"""

