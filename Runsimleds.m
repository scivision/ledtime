% example of using simleds

clear
%% camera imaging
fps = 30; %[Hz] must match your imaging frame rate  (30 fps == 30 Hz)
nscam = 30; %arbitrary number of samples you want to simulate
freqled = [1.5625,3.125, 6.25,12.5]; %[Hz] frequency of flashing

fpgappmoffset = 0; % This is to account for imperfect Digilent FPGA board crystal (parts per million), 
               % 0 means no correction
               % Not sure if we need this, but here it is anyway.
               % it would take many 10000's of samples for this FPGA crystal effect to
               % be significant
               
[ledbool,tcam] = simleds(fps,nscam,freqled,fpgappmoffset); 
%% fire/pps/trig sampling
asicppmoffset = 0;
fs = 1e4; %[Hz], I think in real life we have to use 1e5 or 1e6 due to fire pulse being so narrow 
ns = 1e4; % one second's worth for testing initially

[firebool,tfire] = simfire(fs,ns,fps,asicppmoffset);
%% plot camera
figure(10),clf(10)
nled = length(freqled);

for iled = 1:nled
    subplot(nled,1,iled)
    plot(tcam,ledbool(:,iled))
    xlabel('time [sec.]')
    ylabel('LED (boolean)')
    title(['Simulated ',num2str(freqled(iled)),'Hz LED, fs=',num2str(fps),'Hz,  number of samples: ',int2str(nscam)])
end

%% plot fire/pps/trig
figure(21),clf(21)

plot(tfire,firebool)
xlabel('time [sec.]')
ylabel('boolean')
legend('1PPS','ExtTrig','Fire')
title('simulated fire/trig/pps logical lines')
