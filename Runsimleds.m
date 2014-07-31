% example of using simleds

clear

fs = 1000; %[Hz] must match your measurement sammple rate
ns = 1e3; %arbitrary number of samples you want to simulate
freqled = [6.25,12.5, 25, 50]; %[Hz] frequency of flashing

ppmoffset = 0; % This is to account for imperfect Digilent FPGA board crystal (parts per million), 
               % 0 means no correction
               % Not sure if we need this, but here it is anyway.
               % it would take many 10000's of samples for this FPGA crystal effect to
               % be significant

[ledbool,t] = simleds(fs,ns,freqled,ppmoffset); 

figure(10),clf(10)
nled = length(freqled);
%%
for iled = 1:nled
    subplot(nled,1,iled)
    plot(t,ledbool(:,iled))
    xlabel('time [sec.]')
    ylabel('LED (boolean)')
    title(['Simulated ',num2str(freqled(iled)),'Hz LED, fs=',num2str(fs),'Hz,  number of samples: ',int2str(ns)])
end
