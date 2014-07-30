function firedata = firereader(datfn)
% Michael Hirsch July 2014
% reads "fire.dat" 8-bit binary files
samplesPerSecond = 1000; %a priori
fid = fopen(datfn);
i = 1;
firedata = zeros(1e6,1,'uint8'); % a wild guess at preallocation
try
    
while ~feof(fid) % a hack
    cind = ((i-1)*samplesPerSecond + 1): (i*samplesPerSecond);
    currdata = fread(fid,samplesPerSecond,'uint8=>uint8',0,'l'); %for debugging, I use this temp variable
    if length(currdata) == 0, continue, end %we hit end of file, right on perfectly
    firedata(cind,1) = currdata;
    i = i+1;
end

catch excp
    display(['error on read attempt #',int2str(i-1)])
    display(length(currdata))
    rethrow(excp)
end
firedata((i-1)*samplesPerSecond:end) = []; %throw away unused preallocated values

fclose(fid);





end