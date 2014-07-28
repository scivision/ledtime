% retrieves LED 1-D data from huge files and plots
% Michael Hirsch
% Jan 2012, as modified July 2014

global firstrun
firstrun = true;
addpath('../cv-hst') % This is where rawDMCreader.m lives--trying to keep one 
%                      authoritative copy of programs
%% user parameters
iLED = 4;  %choosing a single LED
%iLED = 1:8; % chooses all 8 LEDs

frameReq = 1:200; %choose frame indices to read

%fn1 = '150fpsX1387.fits';
fn1 = 'e:/2014-07-25/2014-07-25T00-35-CamSer1878.DMCdata';
%% load first file
if ~exist('DataPoints','var') 
[Nf,NumLED,pCol,pRow,t,hMain] = TiffProto3(fn1,iLED,frameReq);

%plot first file
[axs,DataPoints]=FinalPlot(fn1,frameReq,NumLED,pCol,pRow,t,hMain,[],1);
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
for isp = iLED
   subplot(3,3,isp)
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
