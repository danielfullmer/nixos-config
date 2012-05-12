#!/usr/bin/python
import sys, tempfile
if sys.version_info < (3, 0):
    # Python 2.7 code:
    import sys, urllib2, tempfile

    url  = sys.argv[1]
    tmpf = sys.argv[2]

    f    = open(tmpf, "w")
    data = urllib2.urlopen(url)
    f.write(data.read())
    f.close()
else:
    # Python3 code:
    import urllib.request, urllib.error, urllib.parse

    url  = sys.argv[1]
    tmpf = sys.argv[2]

    data = urllib.request.urlretrieve(url,tmpf)
