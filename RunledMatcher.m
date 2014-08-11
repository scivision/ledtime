%RunledMatcher
clear

showLines = false; %optional
showImage = false;

%pick one or the other (or neither) but not both
% showLines must also be true for these to work
showMeasBool = false;
showMeasRaw = true;
rawylim =  [1000,1500]; %arbitrary, so huge spikes don't mess up graph


%path = 'D:\2014-07-31cam1878\';
path = '~/Z/cygdrive/d/2014-07-31cam1878/';

cam1fn = '2014-07-31T19-51-CamSer1878.DMCdata';

cam1fn = [path,cam1fn];


addpath('../hist-utils') % wherever rawDMCreader.m lives

cam1simoffset =  6;  %POSITIVE INTEGER % this one-time slide matches the random LED start to 
                    % the first observation -- should be constant for the rest of the file!

%%
fps = 30;    %[Hz] must match your imaging frame rate  (30 fps == 30 Hz)
nscam = 30000; %arbitrary number of samples you want to simulate ( 1000 seconds in this case, from 30000samples/30samples/sec = 1000 sec)
freqled = [1.5625,3.125, 6.25,12.5]; %[Hz] frequency of flashing
NumLED = 1:2;
secondsToRead = 1:15; % vector of seconds you want to read

fpgappmoffset = 0; % This is to account for imperfect Digilent FPGA board crystal (parts per million), 
               % 0 means no correction
               % Not sure if we need this, but here it is anyway.
               % it would take many 10000's of samples for this FPGA crystal effect to
               % be significant
               
%%
global isoctave
isoctave = logical(exist('OCTAVE_VERSION','builtin'));
[ledbool,tcam,isamp] = simleds(fps,nscam,freqled(NumLED),fpgappmoffset); 

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

ClickFile1 = [name1,'_Coord.h5'];

display(['using file ',ClickFile1,' for LED pixel coordinates'])

rc = transpose(h5read(ClickFile1,'/ledrowcol')); %tranpose b/c matlab 
row = rc(:,1);
col = rc(:,2);

%% load real camera data
doflipud = true; %orients data in accord with your _Coord.h5 file
dotranspose = true;

for sec = secondsToRead
    frameReq = ((sec-1)*fps + 1) : (sec*fps); %we'll grab these from disk to work with, these are the sample indices of this second 
    display(['reading frames ',int2str(frameReq(1)),' to ',int2str(frameReq(end))])
    jFrm = 0;
    for iFrm = frameReq
        jFrm = jFrm+1;
        ImageData = readFrame(cam1fn,ext1,iFrm,doflipud,dotranspose); %read current image from disk

        if showImage
            figure(22)%#ok<*UNRCH> %,clf(22)
            imagesc(ImageData),colormap(gray)
            set(gca,'ydir','normal','clim',[1000 1200])
            line(col,row,'color','r','marker','.','linestyle','none'); 
            colorbar
        end
        
        jLED = 0;
        for iLED = NumLED
            jLED = jLED+1;
            DataPoints(jFrm,jLED) = ImageData(row(iLED),col(iLED));  %pull out the data number for this LED for this frame
       end
    end
   
    
    
%% compare observed with sim
    booldata = bsxfun(@minus,double(DataPoints), mean(DataPoints,1)) > 0; %convert to boolean (not 100% reliable)
    simtind = frameReq+cam1simoffset;
    simbool = ledbool(simtind,:);

    tn = 1:fps; %sample instances
    %for each LED, at the sample times isamp, does the measurement match simulation?
    for jLED = 1:length(NumLED)
       %implement offset
       isampoffs{jLED} = isamp{jLED} - cam1simoffset; %#ok<*SAGROW> % minus shifts back like simbool
       CompareBool = ismember(frameReq,isampoffs{jLED}); %these are the samples upon which we'll compare simulated and measured LED
       comparedatabool = booldata(CompareBool,jLED);
       comparesimbool = simbool(CompareBool,jLED);
       tnisamp{jLED} = tn(CompareBool);
       comparisonResult{jLED} = (comparedatabool == comparesimbool);
       comparisonSummary(sec,jLED) = all(comparisonResult{jLED});
    end

    
    if showLines
        figure(100+sec),clf(100+sec)
        for ipl = 1:length(NumLED)
            ax = subplot(length(NumLED),1,ipl);
            if showMeasBool
                line(tn,booldata(:,ipl),'color','b')
                line(tn,simbool(:,ipl),'color','r')
            end
            if showMeasRaw
               ax = plotyy(tn,DataPoints(:,ipl),1:fps,simbool(:,ipl));
               if ~isempty(rawylim), set(ax(1),'ylim',rawylim), end
               set(ax(2),'ylim',[-0.01,1.01])
               ylabel(ax(2),['sim. LED ',int2str(NumLED(ipl))])
            end
            %plot sample locations
            for ismp = 1:length(tnisamp{ipl})
%                 ct = isampoffs{ipl}(ismp); % index of this second that sample was taken at
                 ct = tnisamp{ipl}(ismp);
                 line([ct,ct],[0,1],'color','r','parent',ax(2))
            end
            
            
            ylabel(ax(1),['meas. LED ',int2str(NumLED(ipl))])
        end
        xlabel(['sample index from t=',num2str(sec)])
        annotation('textbox',[0.4,0.95,0.3,0.05],...
                   'string',['ledOffset=',int2str(cam1simoffset)],...
                   'HorizontalAlignment','center')
    end %if

%----------- this method is bad, it messes up at transistions
%   Nmatch(sec,:) = sum(booldata == simbool); %#ok<SAGROW>
%     if any(Nmatch(sec,:)/length(booldata) < 0.97)
%         warning(['large percentage of mismatches in second ',int2str(sec)])
%     end
%----------
    if showLines || showImage, pause(1), end
end

%% summary
if all(comparisonSummary==true)
    display('******************************')
    display(['seconds ',num2str(secondsToRead(1)),' to ',num2str(secondsToRead(end)),' matched: simulation and measurement for LEDs: ',int2str(NumLED)])
    display('******************************')
else
    display('LED match results: ')
    display('LED 1   LED2')
    display(comparisonSummary)

end

