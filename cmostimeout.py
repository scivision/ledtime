#!/usr/bin/env python3
"""
Reads Calgary sCMOS .out timing files

tk0: FPGA tick when frame was taken. In this test configuration of internal trigger,
it basically tells you, yes, the FPGA is running and knows how to count. The FPGA
timebase could have large error (yielding large absolute time error) and yet
this column would be exactly the same.

tk1: FPGA tick after frame was retrieved, apparently to compare with 'elapsed' column

elapsed: PC clock relative time since acquisition start, when frame was retrieved vis-a-vis tk1


Michael Hirsch
"""
from numpy import arange
from pathlib import Path
from pandas import read_csv
from matplotlib.pyplot import figure,subplots
import seaborn as sns
sns.set_context('talk',font_scale=1.5)
#%% user parameters
fps = 20
fn = Path('~/Dropbox/CMOScalgary/test_clock2.out').expanduser()
dtExpected = 1/fps
tick_sec = 1/40e6 # we suppose the FPGA clock cycle is 40MHz. tick_sec is the period of the tick, assuming zero timebase error (real life timebase has substantial error)
#%% parse data
# sep uses regex for "one or more spaces"
data = read_csv(fn,sep='\s{1,}',skiprows=14,skipfooter=1,engine='python',
                header=None, usecols=(1,2,3),
                names=['elapsed','tk1','tk0'])

N=data.shape[0]
#%% per frame error

dtick = data['tk1'].diff()
dtick_sec = dtick*tick_sec
print(dtick_sec.describe())

dt = data['elapsed'].diff()
print(dt.describe())

fg,axs = subplots(1,2)

ax = axs[0]
ax.set_title('PC time')
dterr = dt - dtExpected
dterr.hist(ax=ax,bins=100)

ax = axs[1]
ax.set_title('FPGA time')
dtickerr = dtick_sec - dtExpected
dtickerr.hist(ax=ax,bins=100)

fg.suptitle('Per-frame timing error, N={}  fps={}'.format(N,fps),size='xx-large')
for a in axs:
    a.set_yscale('log')
    a.set_xlabel('time error [sec.]')
#%% accumulated error (bias)
expectedElapsed = arange(N) * dtExpected
elapsedError = data['elapsed'] - expectedElapsed

ax = figure().gca()
ax.plot(expectedElapsed,elapsedError)
ax.set_title('Cumulative timing error, N={}  fps={}'.format(N,fps))
ax.set_xlabel('True elapsed time [sec.]')
ax.set_ylabel('Accumulated Error [sec.]')
ax.grid(True)