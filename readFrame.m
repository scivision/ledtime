function frame = readFrame(fn,frameInd)
%
% inputs:
% -------
% fn: filename to load
% frameInd: [start,step,stop] or [start,stop]
%
% output:
% -------
% frame: data frame(s) loaded, XxYxP frames 

[~,~,ext] = fileparts(fn);
%%
switch lower(ext)
	case {'.tif','.tiff'}
      frame = imread(fn,'Index',frameInd);
  case '.dmcdata'
      frame = rawDMCreader(fn,'framereq',frameInd);
	case '.fits'
      if length(frameInd)==3
          octind = int2str(frameInd(1)),':',int2str(2),':',int2str(frameInd(3));
          matind = [frameInd(1),frameInd(2),frameInd(3)];
      else
          octind = int2str(frameInd(1)),':',int2str(frameInd(end));
          matind = [frameInd(1), frameInd(end)];
      end

      if isoctave
          ffn = [fn,'[*,*,',octind,']'];
          try
              frame = transpose(read_fits_image(ffn));
          catch
              pkg load fits
              frame = transpose(read_fits_image(ffn));
          end
      else
          pinf = fitsinfo(fn);
          ps = pinf.PrimaryData.Size;
          frame = fitsread(fn,'primary','PixelRegion',{[1 ps(1)],[1 ps(2)],matind});
      end
end %switch

end %function