function [simled, t, isamp] = simleds(fs,ns,freqreq,ppmoffset)
% Michael Hirsch
% july 2014
% simulates what flashing LEDs should do with a real clock (error simulated
% by ppmoffset variable
%
% inputs:
% ns: number of samples of fake LEDs to make
% fs: sampling frequency (i.e. camera frame rate) [Hz] (must match that of your measurements)
% freqs: frequency of each LED [Hz]
% ppmoffset: correction factor for the percentage error in FPGA clock, in
%            parts per million (ppm)
%            1 ppm = 0.0001% = 1e-6
%
% outputs:
% simled: ns x nled boolean values of what the camera would see of the LED
% t: the sampled times

if nargin<4, ppmoffset = 0; end

freqs = freqreq * (1 + ppmoffset*1e-6);

Ts = 1/fs;

t(:,1) = (0:ns-1) * Ts;

nfreq = length(freqs);

%simled = false(ns,nfreq);


phase = [0,-pi/2,-3/2*pi];
phase = phase(1:nfreq)
%for ifreq = 1:nfreq
    %simled(:,jfreq) = logical(square(t*(2*pi)*freq) +1); % +1 corrects for DC offset
 %   cosled(:,ifreq) = cos(t*(2*pi)*freqs(ifreq) + phase(ifreq));
  %  simled(:,ifreq) =  > 0; %#ok<AGROW>
%end

cosled = cos(bsxfun(@plus, bsxfun(@times,t*(2*pi),freqs), phase));
simled = cosled > 0;

display(['LED periods [sec.]: ', num2str(1./freqs)])
display(['sampling period Ts [Hz]: ',num2str(Ts)])

%% find where cos() = +- 1
% I want to take a sample of the LED from the image at every t = pi*n/(2*pi*f) as per
% manual analysis, where n is a positive integer.
% t is in continuous time, but computers work in discrete time, so we
% divide by sampling time Ts to find the discrete time index corresponding
% to that t in continuous time
% that is, I want to make a vector isamp consisting of every pi/(2*pi*f*Ts) sample

sampinterval = pi./(2*pi*freqs*Ts)  %#ok<*NOPRT> % this is interval of sampling (every nth sample)
sampoffset = abs(phase./(2*pi*freqs*Ts)) + 1 % plus 1 is b/c Matlab is one-based indexing

% I must use a cell here because by inspection different frequencies will
% have different length of isamp vector!

% DON'T ROUND indices until this step -- otherwise you'll build up big cumulative
% indexing errors! Don't use fix()
for i = 1:nfreq
    isamp{i} = round(sampoffset(i):sampinterval(i):ns); %#ok<*AGROW>
end %for
end