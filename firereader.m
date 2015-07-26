function [booldata,fs,t] = firereader(datfn,Nbool,secondsToRead,sampleRate)
% Michael Hirsch July 2014
% reads "fire.dat" 8-bit binary files

if isoctave
    pkg('load','communications')
end
%%
if ~exist(datfn,'file')
    error([datfn,' not found'])
end

fid = fopen(datfn);
if ~isempty(sampleRate)
    nheadbytes=0;
    fs = sampleRate;
else %use sample rate of file (normally do this)
    nheadbytes=8;
    fs = fread(fid,1,'double=>double',0,'l'); % get sample rate from "header" of file
end
if fs<1 || fs>1e9
    error('we appear to not be reading fs correctly, please check .fire file first 64 bits with hex editor')
end
% a guess at preallocation
%booldata = false(20e6,Nbool); 
%%
nt = length(secondsToRead);
bytesPerSecond = fs*1; %right now we only use the first 3 bits of the byte, didn't need more than one byte
try 

booldata = false(nt*fs,Nbool);
for isec = 1:nt
    
    if feof(fid), break,end
    
    i = secondsToRead(isec); % i is the second you're reading
	  cind = ((i-1)*fs + 1): (i*fs);
    
    fseek(fid,(i-1)*bytesPerSecond + nheadbytes,'bof');
    % =>double for Octave Comms v.1.2.1 compat (bug in pkg won't accept uint8)
    % doesn't take any longer in Octave or Matlab
    currdata = fread(fid,bytesPerSecond,'uint8=>double',0,'l'); 
    
%     if any(currdata>2^Nbool)
%         error('We appear to not be reading your boolean data correctly')
%     end
    
    if isempty(currdata)
		continue %we hit end of file, right on perfectly
	elseif length(currdata) ~= length(cind)
		display(['discarded ',int2str(length(currdata)),' fire pulses at the end.'])
		continue
    end
    
    currbool = de2bi(currdata,Nbool,2,'left-msb');
    booldata(cind,1:Nbool) = currbool;
    
    %firedata(cind,1) = currdata;
end

catch excp
	display(i)
	display(size(currdata))
	rethrow(excp)
end

%firedata(i*fs:end) = []; %throw away unused preallocated values
% TODO this is so inefficient, just use a "jsec" type variable to only
% assign needed values!
booldata((secondsToRead(end)*fs+1):end,:) = [];
booldata(1:((secondsToRead(1)-1)*fs),:) = [];

fclose(fid);
%%
if nargout>2, t(:,1) = (0:length(booldata)-1)/fs + secondsToRead(1);

end
