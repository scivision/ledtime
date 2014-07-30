function [booldata,fs] = firereader(datfn,Nbool)
% Michael Hirsch July 2014
% reads "fire.dat" 8-bit binary files

if logical(exist('OCTAVE_VERSION','builtin'))
pkg load communications
end

if ~exist(datfn,'file'), error([datfn,' not found']), end

fid = fopen(datfn);
fs = fread(fid,1,'double=>double',0,'l'); % get sample rate from "header" of file
i = 0;
%firedata = zeros(1e6,1,'uint8'); % a wild guess at preallocation
booldata = false(1e6,Nbool); 

try 

while ~feof(fid) 
    i = i+1;
	cind = ((i-1)*fs + 1): (i*fs);
    currdata = fread(fid,fs,'uint8=>uint8',0,'l'); 
	if isempty(currdata)
		continue %we hit end of file, right on perfectly
	elseif length(currdata) ~= length(cind)
		display(['discarded ',int2str(length(currdata)),' fire pulses at the end.'])
		continue
	end 

	booldata(cind,1:Nbool) = logical(de2bi(currdata,Nbool,'left-msb'));
    %firedata(cind,1) = currdata;
end

catch excp
	display(i)
	display(size(currdata))
	rethrow(excp)
end

%firedata(i*fs:end) = []; %throw away unused preallocated values
booldata((i*fs):end,:) = [];

fclose(fid);

end