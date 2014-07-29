function booldata = firereader(datfn,samplerate,Nbool)
% Michael Hirsch July 2014
% reads "fire.dat" 8-bit binary files

if logical(exist('OCTAVE_VERSION','builtin'))
pkg load communications
end

fid = fopen(datfn);
i = 0;
%firedata = zeros(1e6,1,'uint8'); % a wild guess at preallocation
booldata = false(1e6,Nbool); 

while ~feof(fid) 
    i = i+1;
	cind = ((i-1)*samplerate + 1): (i*samplerate);
    currdata = fread(fid,samplerate,'uint8=>uint8',0,'l'); 
	if isempty(currdata), continue, end %we hit end of file, right on perfectly

	booldata(cind,1:Nbool) = logical(de2bi(currdata,Nbool,'left-msb'));
    %firedata(cind,1) = currdata;
end

%firedata(i*samplerate:end) = []; %throw away unused preallocated values
booldata((i*samplerate):end,:) = [];

fclose(fid);

end