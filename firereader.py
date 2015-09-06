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

first 1024 bytes are header (with lots of spare space),
so don't start reading boolean till byte 1024 (zero-based indexing)

Note: the np.int64 are used because some computations actually need 64-bit integers. Best to keep one integer data type in these programs to avoid weird bugs.

"""
from __future__ import division,absolute_import
from numba import jit
from os.path import expanduser
from dateutil.parser import parse
from datetime import datetime
from six import string_types,integer_types
from pytz import UTC
import numpy as np
from warnings import warn
try:
    from matplotlib.pyplot import figure,show
except:
    pass

epoch = datetime(1970,1,1,tzinfo=UTC)
headerlengthbytes = 1024

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
        # read HEADER
        Ts,fps = np.fromfile(f,dtype=np.int64,count=2)
        print('samples/sec: {}   frames/sec: {}  file: {}'.format(Ts,fps,firefn))

        #skip to data area, header is 1024 bytes long, so goto byte 1024 (zero-based index)
        f.seek(headerlengthbytes)

        #NOTE: A for loop with f.seek() could read just the tiny parts of the fire file where matches are supposed to occur.
        #this could give speed/RAM advantages if necessary

        # read DATA as it comes off disk, as uint8
        bytedat = np.fromfile(f,dtype=np.uint8)
#%% find first fire pulse, this is where ut1start should correspond to.
    """ note we do this with "bytedat" because we want to avoid converting bytes
    to bits as that operation is RAM-expensive (takes at least 8 times the RAM)
    """
    firstfireind = find_first(7,bytedat)
#%% take samples to search for fire
    floatstride = Ts/fps
    strideind = np.rint(np.arange(firstfireind,bytedat.size,floatstride)).astype(np.int64) #round to nearest integer
#%% search for fire pulses corresponding to each Ext Trig pulse
    ut1_unix = matchtrigfire(bytedat,strideind,ut1,fps)
#%% debug booldat for plotting
    # this line uses 8 times as much RAM as bytedata, e.g. 4GB for 500MB file
    booldat = np.unpackbits(bytedat[:500][:,None],axis=1)[:,-3:] #take first 500 samples to avoid overwhelming matplotlib

    return ut1_unix,booldat

def find_first(item, vec):
    """return the index of the first occurence of item in vec
    inputs:
    -------
    vec: 1-D array to search for values
    item: scalar or 1-D array of values to search vec for

    credit: tal
    http://stackoverflow.com/questions/7632963/numpy-find-first-index-of-value-fast
    """
    @jit # Numba jit uses C-compiled version of the code in this function
    def find_first_iter(item,vec):
        for v in range(len(vec)):
            for i in item:
                if i == vec[v]:
                    return v

    @jit
    def find_first_sing(item,vec):
        for v in range(len(vec)):
            if item == vec[v]:
                return v


    if isinstance(item,(tuple,list)):
        return find_first_iter(item,vec)
    else:
        return find_first_sing(item,vec)


def matchtrigfire(bytedat,strideind,ut1start,fps):
    bytesel = bytedat[strideind]

    kineticsec = 1./fps

    i=0
    ut1 = []
    for b in bytesel:
        if b in (5,7): #trig+fire or trig+gps+fire
            ut1.append(ut1start+i*kineticsec)
        elif b in (4,6):
            warn('camera failed to take image at fire sample # {}'.format(i))
        else:
            warn('undefined measurement {} at fire sample # {}'.format(b,i))
        i+=1 #must advance whether fire happened or not

    return ut1

def plotfirebool(ut1,booldat):
    print('first/last camera frame {} / {}'.format(datetime.fromtimestamp(ut1[0], tz=UTC),
                                                   datetime.fromtimestamp(ut1[-1],tz=UTC)))

    ax = figure().gca()
    ax.plot(booldat)
    ax.set_ylim(-0.01,1.01)
    ax.set_ylabel('boolean value')
    ax.set_xlabel('sample #') #FIXME label with UT1 time
    ax.legend(('trig','gps','fire'))


if __name__ == '__main__':
    from time import time
    from argparse import ArgumentParser
    p = ArgumentParser(description='convert .fire files to UT1 time')
    p.add_argument('firefn',help='.fire filename') #'~/data/solis_runtime175.fire'
    p.add_argument('ut1start',help='UT1 start time of camera from NMEA GPS yyyy-mm-ddThh:mm:ssZ') #'2015-09-01T12:00:00Z'
    p = p.parse_args()

    tic = time()
    ut1,booldat = getut1fire(p.firefn,p.ut1start)
    print('{:.4f} sec. to read and convert to UT1'.format(time()-tic))
    try:
        plotfirebool(ut1,booldat)
        show()
    except:
        pass
