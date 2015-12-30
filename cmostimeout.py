#!/usr/bin/env python3
"""
Reads Calgary sCMOS .out timing files

Assumption: tElapsed is time to start of exposure.

Michael Hirsch
"""
from numpy import arange
from pathlib import Path
from pandas import read_csv
from matplotlib.pyplot import figure
import seaborn as sns
sns.set_context('talk',font_scale=1.5)
#%% user parameters
fps = 20
fn = Path('~/Dropbox/CMOScalgary/test_clock2.out').expanduser()
dtExpected = 1/fps
#%% parse data
# sep uses regex for "one or more spaces"
data = read_csv(fn,sep='\s{1,}',skiprows=14,engine='python',header=None, usecols=(1,2,3),
                names=['elapsed','tk1','tk0'])

data = data.iloc[:-1,:] #manually dropping the blank last line of the file
N=data.shape[0]
#%% per frame error
dt = data['elapsed'].diff()
print(dt.describe())

ax = figure().gca()
dterr = dt - dtExpected
dterr.hist(ax=ax,bins=100)
ax.set_yscale('log')
ax.set_title('Per-frame timing error, N={}  fps={}'.format(N,fps))
ax.set_xlabel('time error [sec.]')
#%% accumulated error (bias)
expectedElapsed = arange(N) * dtExpected
elapsedError = data['elapsed'] - expectedElapsed

ax = figure().gca()
ax.plot(expectedElapsed,elapsedError)
ax.set_title('Cumulative timing error, N={}  fps={}'.format(N,fps))
ax.set_xlabel('True elapsed time [sec.]')
ax.set_ylabel('Accumulated Error [sec.]')
ax.grid(True)