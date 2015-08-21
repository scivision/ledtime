%%runs the firereader program for the example fire.dat file
%
% Inputs:
% -------
% firefn: .fire file to read
% tstart: UTC time of first first pulse, typically obtained from GPS NMEA
% secondstoread: must start at 1, and extends up to however many seconds. We need to make this to be able to start at arbitrary time
% fps: this is how many pulses per second are emitted from the Ext Trig pin of the ASIC
%
% Notes:
% 1PPS is from the GPS unit, hopefully within 250ns of true time anywhere on Earth
% ExtTrig is what the X-series PCIe-6321 NI-STC3 ASIC derives from 1PPS
% fire is the camera "answering back" logical 1
function RunFireReader(varargin)
%%
p = inputParser();
addRequired(p,'firefn')
addRequired(p,'fps') %TODO read from ASIC config file
addOptional(p,'tstart',datenum(2015,8,1,0,0,0)) %TODO get from NMEA
addParamValue(p,'secondstoread',1) %#ok<*NVREPL> %TODO this only allows starting from t=0, you can't skip ahead
addParamValue(p,'verbose',false) % make lots of plots
p.parse(varargin{:})
U = p.Results;

[datadir,name,ext] = fileparts(U.firefn);
firefn = [datadir,'/',name,'.fire'];
%%
Nbool = 3; %how many data lines were read
[firedata, fs,t] = firereader(firefn,Nbool,U.secondstoread);

%what time where the images taken?
ifire = find(firedata(:,1)>0);
tfire = U.tstart + (ifire-1)*1./U.fps./86400; %UTC time each frame was taken
%%
doplots(firedata,fs,t,Nbool,firefn,U.verbose)

end %function

function doplots(firedata,fs,t,Nbool,firefn,verbose)

%% plot all together
allplot(firedata,fs,t,Nbool,firefn);
%% zoomed view of all together
try
    zoomax = allplot(firedata,fs,t,Nbool,firefn);
    set(zoomax,'xlim',[-0.001,0.03])
end %_try_catch

%% plot separately, on same time axis
if verbose
    if Nbool>1
        figure(12),clf(12)
        plot(t, firedata(:,2))
        %area(uint8(firedata(:,2)))
        ylabel('1PPS')
        xlabel('time (sec)')
        title({'Pulse per second:  ',firefn})
    end

    if Nbool>2
        figure(13),clf(13)
        plot(t, firedata(:,3))
        %area(uint8(firedata(:,3)))
        ylabel('ExtTrig')
        xlabel('time (sec)')
        title({'External Trigger:  ',firefn})
    end
end %if verbose
end %function

function ax = allplot(firedata,fs,t,Nbool,firefn)
    figall=figure;
    ax=axes('parent',figall,'nextplot','add');
    if Nbool>1
        plot(t,firedata(:,2),'r','displayname','1PPS','parent',ax)
        if Nbool>2
            plot(t,firedata(:,3),'k','displayname','ExtTrig','parent',ax)
        end %if
    end %if
    plot(t,firedata(:,1),'b','displayname','fire','parent',ax) %plot last so they'll be on top!
    xlabel(ax,'time (sec)')
    ylabel(ax,'fire boolean')
    title(ax,{[int2str(fs),' samples/sec: '],firefn},'interpreter','none')
    set(ax,'ylim',[-0.01,1.01])
    legend('show')
end %function