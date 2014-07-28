% Image read test
% Michael Hirsch
% Jan 2012
function [Nf,iLED,pCol,pRow,t,hMain] = TiffProto3(fn,iLED,frameReq)

enableClicking = true;

if ~exist(fn,'file'),error([fn,' does not exist']), end

global isoctave 
isoctave = logical(exist('OCTAVE_VERSION','builtin'));
[~,name,ext] = fileparts(fn);
ProtoFrame = 2; %first non-blank frame is 2

%% get time of frames
switch lower(ext)
	case {'.tif','.tiff'}, %TODO
    case '.dmcdata' 
        %TODO parse .h5 configuration file
        kineticSec =  3.051e-2; %TODO this should be from .h5
        Nf = length(frameReq); %FIXME this should maybe be based on huge file size?
	case '.fits'
        pinf = fitsinfo(fn);
        kind = strcmp(pinf.PrimaryData.Keywords,'KCT');
        frind = strcmp(pinf.PrimaryData.Keywords,'NAXIS3');
        kineticSec = pinf.PrimaryData.Keywords{kind,2};
        Nf = pinf.PrimaryData.Keywords{frind,2};
        if any(frameReq>Nf), error('frame request exceeds number of available frames'), end
end %switch
fps = 1/kineticSec; %FIXME is this actually true? (SDK manual says it is)
t = frameReq*kineticSec;
%% show mouse click results
% first see if we've already saved mouse clicks--if you want to pick new
% points for this image, delete the file <tiffFilename>_Coord.mat
% where <tiffFilename> is the value of the variable "file" set above

ClickFile = [name,'_Coord.h5'];

ProtoImg = readFrame(fn,ext,ProtoFrame);

figure(1)
set(1,'Name','LED Viewer','pos',[30,30,560,420])
hMain.img = imagesc(ProtoImg);
colormap(bone)
%set(gca,'ydir','normal') %no, so that display is consistent with ImageJ
xlabel('Pixel Column #')
ylabel('Pixel Row #')
title('Choose LED')
axis('image')


%% pick LED coordinates

if exist(ClickFile,'file') % mouse clicks were already saved
    if isoctave
        p = load(ClickFile,'-hdf5');
        pCol = p.pCol; pRow = p.pRow;
    else
        pCol = h5read(ClickFile,'/pCol');
        pRow = h5read(ClickFile,'/pRow');
    end
    display(['Using coordinates user saved in file: ',ClickFile])
    line(pCol,pRow,'color','r','marker','.','linestyle','none'); 
elseif enableClicking

htp = title('Choose LED'); %#ok<UNRCH>
   hPm= msgbox(['Please click the locations of your ',num2str(length(iLED)),' LEDs'],'Please Pick Coordinates of LEDs','help');

for i = iLED
    set(htp,'String',['Please click on LED #',num2str(i),' of ',num2str(length(iLED))])
    [pCol(i),pRow(i)] = ginput(1); 
    pRow(i) = round(pRow(i));  %#ok<*AGROW>
    pCol(i) = round(pCol(i));
    display(['You chose Column #',num2str(pCol(i)),', Row #',num2str(pRow(i))])
end

try close(hPm), end



line(pCol,pRow,'color','r','marker','.','linestyle','none');

display(['saving ',ClickFile])
if isoctave
    save(ClickFile,'pCol','pRow','-hdf5')
else
    h5create(ClickFile,'/pCol',length(iLED),'datatype','int32')
    h5write(ClickFile,'/pCol',pCol)
    h5create(ClickFile,'/pRow',length(iLED),'datatype','int32')
    h5write(ClickFile,'/pRow',pRow)
end

else
    error(['I''m sorry, it appears a "..._Coord.h5" file doesn''t exist for ',fn])
end %if  exist
end %function

