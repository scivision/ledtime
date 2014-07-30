%runs the firereader program for the example fire.dat file
% don't forget to change the 'firefn' filename for your PC.

firefn = 'e:/2014-07-29/fire.dat';
firedata = firereader(firefn);
plot(firedata)
xlabel('sample index')
ylabel('fire boolean')
title('1000 samples/sec fire (sensor is exposing for fire=1)')