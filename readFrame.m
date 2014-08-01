function frame = readFrame(fn,ext,frameInd,doflipud,dotranspose)

if nargin<5, dotranspose = false; end

global isoctave

switch lower(ext)
	case {'.tif','.tiff'}, frame = imread(fn,'tif','Index',frameInd);
    case '.dmcdata' %TODO use rawDMCreader function here 
        xPix = 512; yPix = 512; %FIXME assign programatically
        xBin = 1;   yBin = 1;
        [frame, rawFrameInd] = rawDMCreader(fn,xPix,yPix,xBin,yBin,frameInd);
        

	case '.fits'
        if isoctave
            ffn = [fn,'[*,*,',int2str(frameInd(1)),':',int2str(frameInd(end)),']'];
            try
                frame = transpose(read_fits_image(ffn));
            catch
                pkg load fits
                frame = transpose(read_fits_image(ffn));
            end
        else
            pinf = fitsinfo(fn);
            ps = pinf.PrimaryData.Size;
            frame = fitsread(fn,'primary','PixelRegion',{[1 ps(1)],[1 ps(2)],[frameInd(1) frameInd(end)]});       
        end
end %switch
%% transpose, flip
if dotranspose
    frame = transpose(frame);
end

if doflipud
    frame = flipud(frame);
end

end