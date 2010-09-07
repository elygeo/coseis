#!/usr/bin/env python
"""
Prepare documentation.
"""

import os, re
from docutils.core import publish_string
cwd = os.getcwd()
os.chdir( os.path.join( '..', 'www' ) )

settings = dict(
    strict = True,
    toc_backlinks = None,
    cloak_email_addresses = True,
    initial_header_level = 3,
    stylesheet_path = os.path.join( cwd, 'style.css' ),
)

for f in 'index', 'sord':
    print f
    path = os.path.join( cwd, f ) + '.rst'
    rst = open( path ).read()
    html = publish_string( rst, writer_name='html4css1',
        settings_overrides=settings )
    html = re.sub( '<col.*>\n', '', html )
    html = re.sub( '</colgroup>', '', html )
    open( f + '.html', 'w' ).write( html )

