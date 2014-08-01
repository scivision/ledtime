function [simled, t] = simleds(fs,ns,freqs,ppmoffset)
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

freqs = freqs * (1 + ppmoffset*1e-6);

t(:,1) = (0:ns-1) / fs;

nfreq = length(freqs);

simled = false(ns,nfreq);

jfreq = 0;
for freq = freqs
    jfreq = jfreq +1;
    simled(:,jfreq) = logical(square(t*(2*pi)*freq) +1); % +1 corrects for DC offset
end

display(['LED periods [sec.]: ',num2str(1./freqs)])

end