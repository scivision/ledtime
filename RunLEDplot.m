% retrieves LED 1-D data from huge files and plots
% user clicks on LEDs, output used in RunledMatacher
% Michael Hirsch
% Jan 2012, as modified July 2014

firstrun = true;
addpath('../histutils') % This is where rawDMCreader.m lives
%% user parameters
iLED = 1:4;  %choosing a four led
%iLED = 1:8; % chooses all 8 LEDs

frameReq = 1:200; %choose frame indices to read

%fn1 = '150fpsX1387.fits';
%fn1 = '/media/HST2014image/2014-07-25/2014-07-25T00-35-CamSer1878.DMCdata';
fn1 = '../../data/2014-07-30/2014-07-30T21-36-CamSer1387.DMCdata';
%% load first file
if ~exist('DataPoints','var') 
    [Nf,NumLED,pCol,pRow,t,hMain] = writeclicks(fn1,iLED,frameReq);

    %plot first file
    [axs,DataPoints,firstrun]=FinalPlot(fn1,frameReq,NumLED,pCol,pRow,t,hMain,[],1,firstrun);
else
    display('reusing existing DataPoints values')
end

% work with data points
booldata = bsxfun(@minus,DataPoints, mean(DataPoints,1)) > 0;

% turn into synthetic pulses to count?
leadingedge = diff(booldata)>0;

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
%% we're only using one camera (for now!)
%load second camera
%[Nf,NumLED,pCol,pRow,hMain] = TiffProto3(fn2,iLED);

%plot second camera
%[axs,DataPoints]=FinalPlot(fn2,Nf,NumLED,pCol,pRow,hMain,t,axs,2);

%load third camera
