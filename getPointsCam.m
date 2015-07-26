function comparisonSummary = getPointsCam(...
            comparisonSummary,frameReq,camfn,showImage,NumLED,camsimoffset,ledbool,fps,isamp,secn,tn,...
            showMeasBool,showMeasRaw,showLines,rawylim,clim,camind)

%% load LED coordinates
[datadir,name] = fileparts(camfn);

ClickFile = [datadir,'/',name,'_Coord.h5'];

%display(['using file ',ClickFile,' for LED pixel coordinates'])
if ~isoctave %matlab
    rc = transpose(h5read(ClickFile,'/ledrowcol')); %tranpose b/c matlab 
else %octave
    rcl = load(ClickFile,'-hdf5');
    rc = transpose(rcl.ledrowcol);
end
    
row = rc(:,1);
col = rc(:,2);
%% load data
jFrm = 0; DataPoints=[];
for iFrm = frameReq
    jFrm = jFrm+1;

    ImageData = readFrame(camfn,iFrm); %read current image from disk
    if isempty(ImageData),break,end

    if showImage
        figure(1)%#ok<*UNRCH>
        imagesc(ImageData),colormap(gray)
        set(gca,'ydir','normal','clim',clim)
        line(col,row,'color','r','marker','.','linestyle','none'); 
        colorbar

%             figure(2) 
%             imagesc(ImageData),colormap(gray)
%             set(gca,'ydir','normal','clim',clim2)
%             line(col,row,'color','r','marker','.','linestyle','none'); 
%             colorbar
    end

    jLED = 0;
    for iLED = NumLED
        jLED = jLED+1;
        DataPoints(jFrm,jLED) = ImageData(row(iLED),col(iLED));  %pull out the data number for this LED for this frame
   end
end %for frameReq
%% compare observed with sim
    if isempty(DataPoints),return,end
    
    booldata = bsxfun(@minus,double(DataPoints), mean(DataPoints,1)) > 0; %convert to boolean (not 100% reliable)
    simtind = frameReq+camsimoffset;
    simbool = ledbool(simtind,:);


    %for each LED, at the sample times isamp, does the measurement match simulation?
    for jLED = 1:length(NumLED)
       %implement offset
       isampoffs = isamp{jLED} - camsimoffset; %#ok<*AGROW,*SAGROW> % minus shifts back like simbool
       CompareBool = ismember(frameReq,isampoffs); %these are the samples upon which we'll compare simulated and measured LED
       comparedatabool = booldata(CompareBool,jLED);
       comparesimbool = simbool(CompareBool,jLED);
       tnisamp{jLED} = tn(CompareBool);
       
       comparisonSummary(secn,jLED) = all( comparedatabool == comparesimbool );
    end
%% plot
    if showLines
        updatelineplot(camind*100000+secn,NumLED,fps,tn,secn,booldata,simbool,DataPoints,tnisamp,...
                   rawylim,camsimoffset,showMeasBool,showMeasRaw)
    end
end %function