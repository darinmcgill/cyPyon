#!/usr/bin/env python
from __future__ import print_function

import sys
print(sys.version)
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from subprocess import Popen

Popen("touch Root.pyx",shell=True).wait()
ext = Extension(
    "cyPyon", 
    ["Root.pyx"],
)

setup( 
    name = 'cyPyon', 
    ext_modules = [ext],
    cmdclass = {'build_ext': build_ext},
)
