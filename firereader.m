function [booldata,fs,t] = firereader(datfn,Nbool)
% Michael Hirsch July 2014
% reads "fire.dat" 8-bit binary files

isoctave = logical(exist('OCTAVE_VERSION','builtin'));
if isoctave
pkg load communications
end

if ~exist(datfn,'file'), error([datfn,' not found']), end

fid = fopen(datfn);
fs = fread(fid,1,'double=>double',0,'l'); % get sample rate from "header" of file
i = 0;
%firedata = zeros(1e6,1,'uint8'); % a wild guess at preallocation
booldata = false(20e6,Nbool); 

try 

while ~feof(fid) 
    i = i+1;
	cind = ((i-1)*fs + 1): (i*fs);
    currdata = fread(fid,fs,'uint8=>uint8',0,'l'); 
    
    if any(currdata>2^Nbool)
        error('We appear to not be reading your boolean data correctly')
    end
    
    if isempty(currdata)
		continue %we hit end of file, right on perfectly
	elseif length(currdata) ~= length(cind)
		display(['discarded ',int2str(length(currdata)),' fire pulses at the end.'])
		continue
    end
    
    currbool = de2bi(currdata,Nbool,2,'left-msb');
    if isoctave %FIXME till comms toolbox patched
        booldata(cind,1:Nbool) = logical(currbool);
    else
        booldata(cind,1:Nbool) = currbool;
    end
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
%%
if nargout>2, t(:,1) = (0:length(booldata)-1)/fs;

end
