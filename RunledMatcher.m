%RunledMatcher
clear

showProgress = true; %optional

cam1fn = '~/tmp/2014-07-30T21-36-CamSer1387.DMCdata';

addpath('../cv-hst') % whereever rawDMCreader.m lives

cam1simoffset = 0;  % this one-time slide matches the random LED start to 
                    % the first observation -- should be constant for the rest of the file!
%cam2simoffset = 0; %for the second camera
%%
fps = 30;    %[Hz] must match your imaging frame rate  (30 fps == 30 Hz)
nscam = 3000; %arbitrary number of samples you want to simulate ( 100 seconds in this case )
freqled = [1.5625,3.125, 6.25];%,12.5]; %[Hz] frequency of flashing
NumLED = 1:3;

fpgappmoffset = 0; % This is to account for imperfect Digilent FPGA board crystal (parts per million), 
               % 0 means no correction
               % Not sure if we need this, but here it is anyway.
               % it would take many 10000's of samples for this FPGA crystal effect to
               % be significant
               
[ledbool,tcam] = simleds(fps,nscam,freqled,fpgappmoffset); 

%% plot simulated camera
% figure(10),clf(10)
% nled = length(freqled);
% 
% for iled = 1:nled
%     subplot(nled,1,iled)
%     plot(tcam,ledbool(:,iled))
%     xlabel('time [sec.]')
%     ylabel('LED (boolean)')
%     title(['Simulated ',num2str(freqled(iled)),'Hz LED, fs=',num2str(fps),'Hz,  number of samples: ',int2str(nscam)])
% end
%% load LED coordinates
[path1,name1,ext1] = fileparts(cam1fn);
%[path2,name2] = fileparts(cam2fn);

ClickFile1 = [path1,'/',name1,'_Coord.h5'];
%ClickFile2 = [name2,'_Coord.h5'];

display(['using file ',ClickFile1,' for LED pixel coordinates'])

pCol = h5read(ClickFile1,'/pCol');
pRow = h5read(ClickFile1,'/pRow');

%% load real camera data
doflipud = true; %orients data in accord with your _Coord.h5 file


for sec = 10:12 % read the 10th second, after the camera has properly started up 
    frameReq = ((sec-1)*fps + 1) : (sec*fps); %we'll grab these from disk to work with 
    
    jFrm = 0;
    for iFrm = frameReq
        jFrm = jFrm+1;
        ImageData = readFrame(cam1fn,ext1,iFrm,doflipud); %read current image from disk

        jLED = 0;
        for iLED = NumLED
            jLED = jLED+1;
            DataPoints(jFrm,jLED) = ImageData(pRow(iLED),pCol(iLED)); %#ok<SAGROW> %pull out the data number for this LED for this frame
        end
    end
    
    % let's try to compare observed with sim
    booldata = bsxfun(@minus,double(DataPoints), mean(DataPoints,1)) > 0; %convert to boolean (not 100% reliable)
    
    simbool = ledbool((cam1simoffset+1):(cam1simoffset+fps),:);
    
    if showProgress
        figure(23),clf(23)
        for ipl = 1:length(NumLED)
            subplot(length(NumLED),1,ipl)
            plot(booldata(:,ipl),'b'),hold('on')
            plot(simbool(:,ipl),'r')
            ylabel(['LED ',int2str(NumLED(ipl))])
        end
        xlabel(['sample index from t=',num2str(sec)])
    end
        
    Nmatch(sec,:) = sum(booldata == simbool); %#ok<SAGROW>
    
    if any(Nmatch(sec,:)/length(booldata) < 0.97)
        warning(['large percentage of mismatches in second ',int2str(sec)])
    end
    pause(1)
end