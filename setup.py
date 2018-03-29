#!/usr/bin/env python
from __future__ import print_function
from distutils.core import setup, Extension
from Cython.Distutils import build_ext
from subprocess import Popen

Popen("touch Root.pyx", shell=True).wait()
ext = Extension(
    "cyPyon", 
    ["Root.pyx"],
)

setup( 
    name='cyPyon',
    description='a cython based parser for python object notation',
    url='https://github.com/darinmcgill/cyPyon',
    version='2.0.0',
    ext_modules=[ext],
    license='GPLv3',
    keywords='pyon parser',
    cmdclass={'build_ext': build_ext},
    install_requires=['Cython'],
    classifiers=[  # Optional
        # How mature is this project? Common values are
        #   3 - Alpha
        #   4 - Beta
        #   5 - Production/Stable
        'Development Status :: 4 - Beta',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.6',
    ],
)
