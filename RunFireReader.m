%runs the firereader program for the example fire.dat file
% don't forget to change the 'firefn' filename for your PC.
%
% Notes:
% 1PPS is from the GPS unit, hopefully within 250ns of true time anywhere on Earth
% ExtTrig is what the X-series PCIe-6321 STC-3 ASIC derives from 1PPS, it is supposed to make the camera 
%         take a picture right then. 10^-6 or less error from 1PPS
% fire is the camera "answering back" logical 1 during the sensor exposure, order 10^-6 sec. error hopefully 
%         from ExtTrig

firefn = 'e:/fire3.fire';
Nbool = 3; %how many data lines were read
[firedata, fs] = firereader(firefn,Nbool);

figure(1),clf(1)
hold('on')
plot(firedata(:,1),'b','displayname','fire')
plot(firedata(:,2),'r','displayname','1PPS')
plot(firedata(:,3),'k','displayname','ExtTrig')
xlabel('sample index')
ylabel('fire boolean')
title([int2str(fs),' samples/sec fire (sensor is exposing for fire=1)'])
legend('show')
