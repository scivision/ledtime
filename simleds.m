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

freqs(:,1) = freqreq * (1 + ppmoffset*1e-6);

t(:,1) = (0:ns-1) / fs;

nfreq = length(freqs);

%simled = false(ns,nfreq);


phase = [0,-pi/2,-3/2*pi];
for ifreq = 1:nfreq
    %simled(:,jfreq) = logical(square(t*(2*pi)*freq) +1); % +1 corrects for DC offset
    simled(:,ifreq) = cos(t*(2*pi)*freqs(ifreq) + phase(ifreq)) > 0; %#ok<AGROW>
end

display('LED periods [sec.]: ')
display(num2str(1./freqs))

end