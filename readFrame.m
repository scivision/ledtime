function frame = readFrame(fn,frameInd)

[~,~,ext] = fileparts(fn);

switch lower(ext)
	case {'.tif','.tiff'}
        frame = imread(fn,'tif','Index',frameInd);
    case '.dmcdata'
        [frame, rawFrameInd] = rawDMCreader(fn,'framereq',frameInd);
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

end