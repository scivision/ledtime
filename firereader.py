#!/usr/bin/env python3
"""
Example of reading HiST .fire file used to determine UTC time of camera frame

little-endian, MSB is on left

bits we don't use:
7 6 5 4 3

bits we use:
2: Ext Trig (ASIC to camera)
1: GPS 1PPS (long pulse, period 1 second)
0: Fire (camera to ASIC)
"""
from __future__ import division,absolute_import
from numba import jit
from os.path import expanduser
from dateutil.parser import parse
from datetime import datetime
from six import string_types,integer_types
from pytz import UTC
import numpy as np
try:
    from matplotlib.pyplot import figure,show
except:
    pass

epoch = datetime(1970,1,1,tzinfo=UTC)

def getut1fire(firefn,ut1start):
    firefn = expanduser(firefn)
#%% handle starttime
    if isinstance(ut1start,string_types):
        ut1 = (parse(ut1start) - epoch).total_seconds()
    elif isinstance(ut1start,datetime):
        ut1 = (ut1start-epoch).total_seconds()
    elif isinstance(ut1start,(float,integer_types)):
        pass #assuming it's already in UT1 unix epoch
    else:
        raise ValueError('I dont understand the format of the ut1 start time youre giving me')
#%% read data
    #read sample rate and fps.  Both are signed 64-bit integers used directly in indexing operations
    with open(firefn,'rb') as f:
        Ts,fps = np.fromfile(f,dtype=np.int64,count=2)
        print('detected samples/sec of {} with frames/sec {} in file {}'.format(Ts,fps,firefn))

        # data as it comes off disk, as uint8
        bytedat = np.fromfile(f,dtype=np.uint8)[:,None]
#%% find first fire pulse, this is where ut1start should correspond to.
    """ note we do this with "bytedat" because we want to avoid converting bytes
    to bits as that operation is RAM-expensive (takes at least 8 times the RAM)
    """
    firstfireind = find_first(7,bytedat)
#%% take samples to search for fire
    #M = bytedat[firstfireind::fps] #this is missing ext trig , try searching every single sample
#%% search for

    # this line uses 8 times as much RAM as bytedata, e.g. 4GB for 500MB file
#    booldat = np.unpackbits(bytedat,axis=1)

    return booldat

@jit # Numba jit uses C-compiled version of the code in this function
def find_first(item, vec):
    """return the index of the first occurence of item in vec
    credit: tal
    http://stackoverflow.com/questions/7632963/numpy-find-first-index-of-value-fast
    """
    for i in range(len(vec)):
        if item == vec[i]:
            return i

def plotfirebool(booldat):
    ax = figure().gca()
    ax.plot(booldat)


if __name__ == '__main__':
    """ example only, fake times"""

    ut1start  = '2015-09-01T12:00:00Z' # trailing Z makes it UTC
    firefn = 'f:/data/solis_runtime175.fire'

    booldat = getut1fire(firefn,ut1start)
    try:
        plotfirebool(booldat)
        show()
    except:
        pass