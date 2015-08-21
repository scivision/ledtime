%runs the firereader program for the example fire.dat file
% don't forget to change the 'firefn' filename for your PC.
%
% Notes:
% 1PPS is from the GPS unit, hopefully within 250ns of true time anywhere on Earth
% ExtTrig is what the X-series PCIe-6321 NI-STC3 ASIC derives from 1PPS
% fire is the camera "answering back" logical 1
function RunFireReader(varargin)
%%
p = inputParser();
addRequired(p,'bigfn')
addOptional(p,'tstart',datenum(2015,8,1,0,0,0)) %TODO get from NMEA
addParamValue(p,'secondstoread',1:8) %#ok<*NVREPL> %TODO this only allows starting from t=0, you can't skip ahead
addParamValue(p,'fps',30) %TODO read from file
p.parse(varargin{:})
U = p.Results;

[datadir,name,ext] = fileparts(U.bigfn);
firefn = [datadir,'/',name,'.fire'];
%%
Nbool = 3; %how many data lines were read
[firedata, fs,t] = firereader(firefn,Nbool,U.secondstoread);

%what time where the images taken?
ifire = find(firedata(:,1)>0);
tfire = U.tstart + (ifire-1)*1./U.fps./86400; %UTC time each frame was taken
%%
doplots(firedata,fs,t,Nbool,firefn)

end %function

function doplots(firedata,fs,t,Nbool,firefn)

%% plot all together
figure(1),clf(1)
hold('on')
if Nbool>1
    plot(t,firedata(:,2),'r','displayname','1PPS')
    if Nbool>2
        plot(t,firedata(:,3),'k','displayname','ExtTrig')
    end
end
plot(t,firedata(:,1),'b','displayname','fire') %plot last so they'll be on top!

xlabel('time (sec)')
ylabel('fire boolean')
title({[int2str(fs),' samples/sec: '],firefn})
legend('show')
%% plot separately, on same time axis
if Nbool>1
    figure(2),clf(2)
    plot(t, firedata(:,2))
    %area(uint8(firedata(:,2)))
    ylabel('1PPS')
    xlabel('time (sec)')
    title({'Pulse per second:  ',firefn})
end

if Nbool>2
    figure(3),clf(3)
    plot(t, firedata(:,3))
    %area(uint8(firedata(:,3)))
    ylabel('ExtTrig')
    xlabel('time (sec)')
    title({'External Trigger:  ',firefn})
end

end %function