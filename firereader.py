#!/usr/bin/env python3
"""
Example of reading HiST .fire file used to determine UTC time of camera frame
"""
from os.path import expanduser
from dateutil.parser import parse
from datetime import datetime
from six import string_types
from pytz import UTC
import numpy as np

epoch = datetime(1970,1,1,tzinfo=UTC)

def getut1fire(firefn,ut1start):
    firefn = expanduser(firefn)
#%% handle starttime
    if isinstance(ut1start,string_types):
        ut1 = (parse(ut1start) - epoch).total_seconds()
    elif isinstance(ut1start,datetime):
        ut1 = (ut1start-epoch).total_seconds()
    else:
        raise ValueError('I dont understand the format of the ut1 start time youre giving me')
#%% get sample rate
    Ts = np.fromfile(firefn,dtype=np.float64,count=1)[0]
    print('detected samples/sec of {} as {}'.format(firefn,Ts))
    

if __name__ == '__main__':
    """ example only, fake times"""
    
    ut1start  = '2015-09-01T12:00:00Z' # trailing Z makes it UTC
    firefn = 'f:/data/solis_devel205.fire'
    
    ut1 = getut1fire(firefn,ut1start)