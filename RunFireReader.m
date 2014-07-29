%runs the firereader program for the example fire.dat file
% don't forget to change the 'firefn' filename for your PC.

firefn = 'e:/2014-07-29/fire2.dat';
samplerate = 1000; %a priori
Nbool = 2; %how many data lines were read
firedata = firereader(firefn,samplerate,Nbool);

figure(1),clf(1)
hold('on')
plot(firedata(:,1),'b','displayname','fire')
plot(firedata(:,2),'r','displayname','1PPS')
xlabel('sample index')
ylabel('fire boolean')
title('1000 samples/sec fire (sensor is exposing for fire=1)')
legend('show')
