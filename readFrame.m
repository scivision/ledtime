function frame = readFrame(fn,ext,frameInd,doflipud)

global isoctave

switch lower(ext)
	case {'.tif','.tiff'}, frame = imread(fn,'tif','Index',frameInd);
    case '.dmcdata' %TODO use rawDMCreader function here 
        xPix = 512; yPix = 512; %FIXME assign programatically
        xBin = 1;   yBin = 1;
        [frame, rawFrameInd] = rawDMCreader(fn,xPix,yPix,xBin,yBin,frameInd);
        frame = transpose(frame);
	case '.fits'
        if isoctave
            ffn = [fn,'[*,*,',int2str(frameInd),':',int2str(frameInd),']'];
            try
                frame = transpose(read_fits_image(ffn));
                if doflipud
                frame = flipud(frame);
                end
            catch
                pkg load fits
                frame = transpose(read_fits_image(ffn));
                if doflipud
                frame = flipud(frame);
                end
            end
        else
            pinf = fitsinfo(fn);
            ps = pinf.PrimaryData.Size;
            frame = fitsread(fn,'primary','PixelRegion',{[1 ps(1)],[1 ps(2)],[frameInd frameInd]});
            if doflipud
            frame = flipud(frame);
            end
        end
end


end