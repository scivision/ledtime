%runs the firereader program for the example fire.dat file
% don't forget to change the 'firefn' filename for your PC.

firefn = 'e:/firee.dat';
Nbool = 3; %how many data lines were read
[firedata, fs] = firereader(firefn,samplerate,Nbool);

figure(1),clf(1)
hold('on')
plot(firedata(:,1),'b','displayname','fire')
plot(firedata(:,2),'r','displayname','1PPS')
xlabel('sample index')
ylabel('fire boolean')
title([int2str(fs),' samples/sec fire (sensor is exposing for fire=1)'])
legend('show')
