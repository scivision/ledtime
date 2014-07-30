%runs the firereader program for the example fire.dat file
% don't forget to change the 'firefn' filename for your PC.
%
% Notes:
% 1PPS is from the GPS unit, hopefully within 250ns of true time anywhere on Earth
% ExtTrig is what the X-series PCIe-6321 NI-STC3 ASIC derives from 1PPS
% fire is the camera "answering back" logical 1
clear,clc
firefn = '~/junk/2014-07-30T21-36-CamSer1387.fire';
Nbool = 3; %how many data lines were read
[firedata, fs] = firereader(firefn,Nbool);

nt = size(firedata,1);
%plot all together
xl = [1,550e3];
figure(1),clf(1)
hold('on')
plot(firedata(:,2),'r','displayname','1PPS')
plot(firedata(:,3),'k','displayname','ExtTrig')
plot(firedata(:,1),'b','displayname','fire') %plot last so they'll be on top!
set(gca,'xlim',xl)
xlabel('sample index')
ylabel('fire boolean')
title([int2str(fs),' samples/sec fire'])
legend('show')
%now plot separately, on same time axis
figure(2),clf(2)

figure(2),clf(2)
plot(firedata(:,2))
%area(uint8(firedata(:,2)))
ylabel('1PPS')
set(gca,'xlim',xl)

figure(3),clf(3)
plot(firedata(:,3))
%area(uint8(firedata(:,3)))
ylabel('ExtTrig')
set(gca,'xlim',xl)

figure(4),clf(4)
plot(firedata(:,1))
%area(uint8(firedata(:,1)))
ylabel('fire')
set(gca,'xlim',xl)
xlabel('sample index')
