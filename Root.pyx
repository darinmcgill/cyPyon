from __future__ import division
import numpy
cimport numpy
import sys
import datetime
import time
import collections
import os
import re
import cython
import pytz
import math
import pickle
import copy
import struct
from libc.stdlib cimport malloc,free,calloc
from libc.stdint cimport uint64_t,uint16_t,uint32_t,int64_t,uint8_t,int8_t
from libc.string cimport memcpy
from libc.math cimport floor,ceil,trunc
from heapq import heappush,heappop,heapify
import subprocess
from cpython.bytes cimport PyBytes_FromStringAndSize
import select
import signal

cdef extern from "string" namespace "std":
    cdef cppclass string:
        char* c_str()

cpdef test(char c):
    c = not c
    print c

cdef class Tester:
    cdef public int i
    def f(Tester self):
        return self.g()
    cdef g(Tester self):
        raise Exception("foobar")
