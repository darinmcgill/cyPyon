#!/usr/bin/python

import sys
print sys.version
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from subprocess import Popen

Popen("touch Root.pyx",shell=True).wait()
ext = Extension(
    "cyPyon", 
    ["Root.pyx"],
    language="c++",
    #include_dirs=['/usr/local/lib/python2.7/site-packages/numpy/core/include'],
    #extra_compile_args=[ '-std=c++0x' ],
    pyrex_gdb=True,
)

setup( 
    #name = 'Hello world app', 
    name = 'cyPyon', 
    ext_modules = [ext],
    cmdclass = {'build_ext': build_ext},
)
