head = """\
<table>
    <tr>
        <th colspan="3">%(title)s</th>
    </tr>
"""

item = """\
    <tr>
        <td><a href="%(url)s">%(link)-32s</a></td>
        <td>%(mtime)s</td>
        <td>%(size)6s</td>
    </tr>
"""

foot = """\
</table>
"""

