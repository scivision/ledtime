%runs the firereader program for the example fire.dat file
% don't forget to change the 'firefn' filename for your PC.
%
% Notes:
% 1PPS is from the GPS unit, hopefully within 250ns of true time anywhere on Earth
% ExtTrig is what the X-series PCIe-6321 NI-STC3 ASIC derives from 1PPS
% fire is the camera "answering back" logical 1
clear,clc

path = '~/Z/media/aurora1/DriveImages/';
firefn = '2014-07-31cam1878/2014-07-31T19-51-CamSer1878.fire';    %'~/U/collaborate/HST/three.fire';

secondsToRead = 67;

firefn = [path,firefn];

Nbool = 3; %how many data lines were read
[firedata, fs,t] = firereader(firefn,Nbool,secondsToRead);

nt = size(firedata,1);
%% plot all together
figure(1),clf(1)
hold('on')
plot(t,firedata(:,2),'r','displayname','1PPS')
plot(t,firedata(:,3),'k','displayname','ExtTrig')
plot(t,firedata(:,1),'b','displayname','fire') %plot last so they'll be on top!

xlabel('time (sec)')
ylabel('fire boolean')
title({[int2str(fs),' samples/sec: '],firefn})
legend('show')
%% plot separately, on same time axis
figure(2),clf(2)
plot(t, firedata(:,2))
%area(uint8(firedata(:,2)))
ylabel('1PPS')
xlabel('time (sec)')
title({'Pulse per second:  ',firefn})

figure(3),clf(3)
plot(t, firedata(:,3))
%area(uint8(firedata(:,3)))
ylabel('ExtTrig')
xlabel('time (sec)')
title({'External Trigger:  ',firefn})

figure(4),clf(4)
plot(t, firedata(:,1))
%area(uint8(firedata(:,1)))
ylabel('fire')
xlabel('time (sec)')
title({'Fire:   ',firefn})