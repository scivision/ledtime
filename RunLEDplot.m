% retrieves LED 1-D data from huge files and plots
% user clicks on LEDs, output used in RunledMatacher
% Michael Hirsch
% Jan 2012, as modified July 2014
function RunLEDplot(varargin)
addpath('../histutils') % This is where rawDMCreader.m lives
%% user parameters
p = inputParser();
addOptional(p,'bigfn','../../data/2014-07-30/2014-07-30T21-36-CamSer1387.DMCdata')
%fn1 = '150fpsX1387.fits';
%fn1 = '/media/HST2014image/2014-07-25/2014-07-25T00-35-CamSer1878.DMCdata';
addParamValue(p,'iled',1:4) %#ok<*NVREPL> %choosing first four led
addParamValue(p,'framereq', 1:200) %choose frame indices to read
addParamValue(p,'showprogress',false)
p.parse(varargin{:})
U = p.Results;
%% load first file
[NumLED,prowcol,t,hMain] = writeclicks(U.bigfn, U.iled, U.framereq);
%plot first file
DataPoints=FinalPlot(U.bigfn,U.framereq,NumLED,prowcol,t,hMain,1,U.showprogress);
% work with data points
booldata = bsxfun(@minus,DataPoints, mean(DataPoints,1)) > 0;
% turn into synthetic pulses to count?
leadingedge = diff(booldata)>0;
%%
doplot(t,booldata,leadingedge,NumLED)
end %function

function doplot(t,booldata,leadingedge,iLED)
figure(3),clf(3)
if length(iLED) == 1
    plot(t,booldata)
    set(gca,'ylim',[-0.05,1.05])
    xlabel('Time')
    ylabel('Boolean')
    title(['LED #',int2str(iLED)])
else
    if length(iLED)<5
        sprc = 2;
    else
        sprc = 3;
    end
    
    for isp = iLED

         subplot(sprc,sprc,isp)
         plot(t,booldata(:,isp))

         set(gca,'ylim',[-0.05,1.05],'xlim',[t(1),t(end)])
         xlabel('time')
         ylabel('boolean')
         title(['LED #',int2str(iLED(isp))])
    end
end

figure(4),clf(4)
plot(t(1:end-1),leadingedge)
set(gca,'ylim',[-0.05,1.05])
xlabel('Time')
ylabel('leading edge')
title(['LED #',int2str(iLED)])

end %function
