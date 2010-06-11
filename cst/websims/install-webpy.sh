#!/bin/bash -e
#Install wep.py and change static directory location

version='web.py-0.34'

curl -O "http://webpy.org/static/${version}.tar.gz"
tar zxvf "${version}.tar.gz"
rm "${version}.tar.gz"
ln -s "${version}/web" web

patch -p0 << END
diff -rupN web/httpserver-orig.py web/httpserver.py
--- web/httpserver-orig.py  2010-03-25 15:20:06.000000000 -0700
+++ web/httpserver.py   2010-03-25 15:18:36.000000000 -0700
@@ -136,7 +136,7 @@ def runsimple(func, server_address=("0.0
 
     [cp]: http://www.cherrypy.org
     """
-    func = StaticMiddleware(func)
+    func = StaticMiddleware(func, prefix='/websims/static/')
     func = LogMiddleware(func)
     
     server = WSGIServer(server_address, func)
@@ -184,6 +184,7 @@ class StaticApp(SimpleHTTPRequestHandler
         self.wfile = StringIO() # for capturing error
 
         f = self.send_head()
+        self.headers += [ ('Cache-Control', 'max-age=86400') ]
         self.start_response(self.status, self.headers)
 
         if f:
END

#wget -N http://www.cherrypy.org/browser/trunk/cherrypy/wsgiserver/__init__.py?format=raw

