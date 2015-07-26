%RunledMatcher
%use RunLEDplot to click and save files used as input to this file
clear

secondsToRead=1;
%secondsToRead(:,1) = 67; % vector of seconds you want to read
%secondsToRead(:,1) = 1200:40:1400;

showLines = true; %optional
showImage = true; %optional, takes a lot longer to process

%pick one or the other (or neither) but not both
% showLines must also be true for these to work
showMeasBool = false;
showMeasRaw = true;

usecam = [true,false,false]; %cam numbers to use

datadir = '../../data/';

fpgappmoffset = [-1050,-1050,0]; % This is to account for imperfect Digilent FPGA board crystal (parts per million), 
               % 0 means no correction
               % increasingly positive number slides "to the left" earlier in time
               % increasingly negative number slides "to the right" later in time

camsimoffset =  [6,18];  %POSITIVE INTEGER % this one-time slide matches the random LED start to 
                    % the first observation -- should be constant for the rest of the file!
                    % a bigger number slides it "to the left" earlier in time
%% camera 1
clim1 = [1000 1200]; % for image, arbitrary, for easy to see contrast
rawylim1 =  [1000,1500]; %arbitrary, so huge spikes don't mess up graph

cam1fn = '2014-07-30/2014-07-30T21-36-CamSer1387.DMCdata';
%cam1fn = '2014-07-31cam1878/2014-07-31T19-51-CamSer1878.DMCdata';
cam1fn = [datadir,'/',cam1fn];
%% camera 2 
clim2 = [1000 1250];
rawylim2 =  [1000,2500];

cam2fn=[];
%cam2fn = '2014-07-31cam1387/2014-07-31T19-51-CamSer1387.DMCdata';
cam2fn = [datadir,'/',cam2fn];
%%
if ~exist(cam1fn,'file'), usecam(1)=false; end
if ~exist(cam2fn,'file'), usecam(2)=false; end
%% octave/matlab setup
addpath('../histutils') % wherever rawDMCreader.m lives
%% simulation parameters
fps = 30;    %[Hz] must match your imaging frame rate  (30 fps == 30 Hz)
nscam = 86400*fps; %arbitrary number of samples you want to simulate ( 86400 sec is 24 hours)
freqled = [1.5625,3.125, 6.25,12.5]; %[Hz] frequency of flashing
NumLED = 1:2;

nt = length(secondsToRead);
if nt>50 && showLines
    warning('using more than about 40 figures with Matlab can get very slow and use all RAM and even crash.')
    display('** consider showLines=false or decreasing number of seconds read')
end

%% simulate LEDs
% tcam took a lot of RAM, OK to use if you need it though.
if usecam(1)
    [ledbool1,~,isamp1] = simleds(fps,nscam,freqled(NumLED),fpgappmoffset(1)); 
end
if usecam(2)
    [ledbool2,~,isamp2] = simleds(fps,nscam,freqled(NumLED),fpgappmoffset(2));
end
%% load real camera data
tn = 1:fps; %sample instances
comparisonSummary1 = [];
comparisonSummary2 = [];
try
for isec = 1:nt
    secn = secondsToRead(isec);
    tic
    frameReq = ((secn-1)*fps + 1) : (secn*fps); %we'll grab these from disk to work with, these are the sample indices of this second 

    %load cam1 analysis
    if usecam(1)
        comparisonSummary1 = getPointsCam(comparisonSummary1,frameReq,...
               cam1fn,showImage,NumLED,camsimoffset(1),ledbool1,fps,isamp1,...
               secn,tn,showMeasBool,showMeasRaw,showLines,rawylim1,clim1,1);
    end
    %load cam2 analysis
    if usecam(2)
        comparisonSummary2 = getPointsCam(comparisonSummary2,frameReq,...
               cam2fn,showImage,NumLED,camsimoffset(2),ledbool2,fps,isamp2,...
               secn,tn,showMeasBool,showMeasRaw,showLines,rawylim2,clim2,2);
    end

%----------- this method is bad, it messes up at transistions
%   Nmatch(sec,:) = sum(booldata == simbool); %#ok<SAGROW>
%     if any(Nmatch(sec,:)/length(booldata) < 0.97)
%         warning(['large percentage of mismatches in second ',int2str(sec)])
%     end
%----------
    if showLines || showImage, pause(1), end
    display(['read/processed frames ',int2str(frameReq(1)),' to ',int2str(frameReq(end)),' for sec. ',num2str(secn),' in ',num2str(toc,'%0.1f'),' seconds.'])
end %for sec
catch excp
    fprintf('Stopped reading at sec=%f',secn)
    rethrow(excp)
end %try
%% summary
if usecam(1) 
    if all(comparisonSummary1(secondsToRead,:)==true) %test only the seconds tested
        display('******************************')
        display(['cam1: seconds ',num2str(secondsToRead(1)),' to ',num2str(secondsToRead(end)),' matched: simulation and measurement for LEDs: ',int2str(NumLED)])
        display('******************************')
    else
        display('cam1: LED match results: ')
        display('  sec.  LED 1   LED2')
        display([secondsToRead,comparisonSummary1(secondsToRead,:)])
    end
end

if usecam(2)
    if all(comparisonSummary2(secondsToRead,:)==true) %test only the seconds tested
        display('******************************')
        display(['cam2: seconds ',num2str(secondsToRead(1)),' to ',num2str(secondsToRead(end)),' matched: simulation and measurement for LEDs: ',int2str(NumLED)])
        display('******************************')
    else
        display('cam2: LED match results: ')
        display('  sec.  LED 1   LED2')
        display([secondsToRead,comparisonSummary2(secondsToRead,:)])
    end
end