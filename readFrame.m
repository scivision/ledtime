function frame = readFrame(fn,ext,frameInd)

global isoctave

switch lower(ext)
	case {'.tif','.tiff'}, frame = imread(fn,'tif','Index',frameInd);
    case '.dmcdata' %TODO use rawDMCreader function here 
        xPix = 512; yPix = 512; %FIXME assign programatically
        xBin = 1;   yBin = 1;
        [frame, rawFrameInd] = rawDMCreader(fn,xPix,yPix,xBin,yBin,frameInd);
	case '.fits'
        if isoctave
            ffn = [fn,'[*,*,',int2str(frameInd),':',int2str(frameInd),']'];
            try
                frame = flipud(transpose(read_fits_image(ffn)));
            catch
                pkg load fits
                frame = flipud(transpose(read_fits_image(ffn)));
            end
        else
            pinf = fitsinfo(fn);
            ps = pinf.PrimaryData.Size;
            frame = flipud(fitsread(fn,'primary','PixelRegion',{[1 ps(1)],[1 ps(2)],[frameInd frameInd]}));
        end
end


end