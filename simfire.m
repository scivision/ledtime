function [databool,t] = simfire(fs,ns,fps,ppmoffset)
% Michael Hirsch
% july 2014
% simulates what flashing LEDs should do with a real clock (error simulated
% by ppmoffset variable
%
% inputs:
% ns: number of samples of fake LEDs to make
% fs: sampling frequency (i.e. camera frame rate) [Hz] (must match that of your measurements)
% ppmoffset: correction factor for the percentage error in FPGA clock, in
%            parts per million (ppm)
%            1 ppm = 0.0001% = 1e-6
%
% outputs:
% simled: ns x nled boolean values of what the camera would see of the LED
% t: the sampled times
if nargin<3, ppmoffset = 0; end

Nbool = 3; % 1PPS, ExtTrig, Fire

% pulse frequencies
ppsfs = 1; %[Hz] by definition, 1 Hz rate
exttrigfs = fps; %[Hz] the programmed frame rate of the camera

fpsactual = fs * (1 + ppmoffset*1e-6);

t(:,1) = (0:ns-1) / fs;
dp(:,1) = (0:ns-1) / ppsfs;
de(:,1) = (0:ns-1) / exttrigfs;

databool = false(ns,Nbool);

%% 1PPS
ppswidth = 10e-3; %seconds, all we care about is leading edge ( 0 ->1 )
exttrigwidth = 1e-3; %seconds, all we care about is leading edge ( 0 ->1 )

databool(:,1) = pulstran(t,dp,'rectpuls',ppswidth);
databool(:,2) = pulstran(t,de,'rectpuls',exttrigwidth);


end