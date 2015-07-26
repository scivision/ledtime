% Image read test
% Michael Hirsch
% Jan 2012
function [iLED,prowcol,t,hMain] = writeclicks(fn, iLED, frameReq)

enableClicking = true;

if ~exist(fn,'file')
    error([fn,' does not exist']) 
end

[datadir,name,ext] = fileparts(fn);
ProtoFrame = 2; %first non-blank frame is 2

%% get time of frames
switch lower(ext)
	case {'.tif','.tiff'}, %TODO
    case '.dmcdata' 
        %TODO parse .h5 configuration file
        kineticSec =  3.051e-2; %TODO this should be from .h5
        %Nf = length(frameReq); %FIXME this should maybe be based on huge file size?
	case '.fits'
        pinf = fitsinfo(fn);
        kind = strcmp(pinf.PrimaryData.Keywords,'KCT');
        frind = strcmp(pinf.PrimaryData.Keywords,'NAXIS3');
        kineticSec = pinf.PrimaryData.Keywords{kind,2};
        Nf = pinf.PrimaryData.Keywords{frind,2};n
        if any(frameReq>Nf), error('frame request exceeds number of available frames'), end
end %switch
%fps = 1/kineticSec; % (SDK manual says it is)
t = (frameReq-1)*kineticSec;
%% show mouse click results
% first see if we've already saved mouse clicks--if you want to pick new
% points for this image, delete the file <tiffFilename>_Coord.mat
% where <tiffFilename> is the value of the variable "file" set above

ProtoImg = readFrame(fn,ProtoFrame);

figure(1),clf(1)
set(1,'Name','LED Viewer')%,'pos',[30,30,560,420])
hMain.img = imagesc(ProtoImg);
colormap(bone)
%set(gca,'ydir','normal') %no, so that display is consistent with ImageJ
xlabel('Pixel Column #')
ylabel('Pixel Row #')
title('Choose LED')
axis('image')
%% pick LED coordinates
ClickFile = [datadir,'/',name,'_Coord.h5'];
if exist(ClickFile,'file') % mouse clicks were already saved
    try
      if isoctave
        p = load(ClickFile,'-hdf5');
        prowcol = p.prowcol;
      else
        prowcol = h5read(ClickFile,'/prowcol');
      end
      display(['Using coordinates user saved in file: ',ClickFile])
      line(prowcol(:,2), prowcol(:,1), 'color','r','marker','.','linestyle','none'); 
    catch excp
        display(['I couldn''t read ',ClickFile,' properly. Have you changed the number of LEDs used? Try making a new .h5 file'])
        rethrow(excp)
    end
elseif enableClicking

    htp = title('Choose LED'); 
    disp(['Please click the locations of your ',int2str(length(iLED)),' LEDs'])

    for i = iLED
        set(htp,'String',['Please click on LED #',int2str(i),' of ',int2str(length(iLED))])
        [col,row] = ginput(1); 
        prowcol(i,:) = int16([row,col]);
        display(['You chose Row/Col #',int2str(prowcol(i,:))])
    end

    line(prowcol(:,2),prowcol(:,1),'color','r','marker','.','linestyle','none');

    disp(['saving ',ClickFile])
    if isoctave
        save(ClickFile,'prowcol','-hdf5')
    else
        h5create(ClickFile,'/prowcol',[max(iLED),2],'datatype','int16')
        h5write(ClickFile,'/prowcol',prowcol)
    end

    else
        error(['I''m sorry, it appears a "*_Coord.h5" file doesn''t exist for ',fn]) %#ok<*UNRCH>
end %if  exist
end %function

