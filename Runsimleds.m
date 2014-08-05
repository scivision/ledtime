% example of using simleds

clear

dofire = false; %true to generate simulated fire/pps/trig waveforms
%% camera imaging
fps = 30; %[Hz] must match your imaging frame rate  (30 fps == 30 Hz)
nscam = 30; %arbitrary number of samples you want to simulate
freqled = [1.5625,3.125, 6.25,12.5,25,50,100,200]; %[Hz] frequency of flashing

NumLED = 1:3;

fpgappmoffset = 0; % This is to account for imperfect Digilent FPGA board crystal (parts per million), 
               % 0 means no correction
               % Not sure if we need this, but here it is anyway.
               % it would take many 10000's of samples for this FPGA crystal effect to
               % be significant
               
[ledbool,tcam] = simleds(fps,nscam,freqled(NumLED),fpgappmoffset); 
%% fire/pps/trig sampling
if dofire
    asicppmoffset = 0;
    fs = 1e4; %[Hz], I think in real life we have to use 1e5 or 1e6 due to fire pulse being so narrow 
    ns = 1e4; % one second's worth for testing initially
    [firebool,tfire] = simfire(fs,ns,fps,asicppmoffset,dofire);
end
%% plot camera
figure(10),clf(10)

Nled = length(NumLED);

jled = 0;
for iled = NumLED
    jled = jled + 1;
    subplot(Nled,1,jled)
    plot(tcam,ledbool(:,iled))
    xlabel('time [sec.]')
    ylabel('LED (boolean)')
    title(['Simulated ',num2str(freqled(iled)),'Hz LED, fs=',num2str(fps),'Hz,  number of samples: ',int2str(nscam)])
    grid('on')
end

%% plot fire/pps/trig
if dofire
    figure(21),clf(21)

    plot(tfire,firebool)
    xlabel('time [sec.]')
    ylabel('boolean')
    legend('1PPS','ExtTrig','Fire')
    title('simulated fire/trig/pps logical lines')
end