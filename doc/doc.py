#!/usr/bin/env python
"""
Prepare documentation.
"""
import re
from docutils.core import publish_string
settings = dict(
    datestamp = '%Y-%m-%d',
    generator = True,
    strict = True,
    toc_backlinks = None,
    cloak_email_addresses = True,
    initial_header_level = 3,
    stylesheet_path = 'style.css',
)

for f in 'coseis', 'sord', 'cvm':
    print f
    rst = open( f + '.txt' ).read()
    html = publish_string( rst, writer_name='html4css1',
        settings_overrides=settings )
    html = re.sub( '<col.*>\n', '', html )
    html = re.sub( '</colgroup>', '', html )
    open( f + '.html', 'w' ).write( html )

