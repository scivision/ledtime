function coplotbool()
%% plots boolean LED data of cameras together in subplots per LED
%
% note, instead of loading the data from disk, you can use this function with
% the RunLED... main function
%
% Michael Hirsch, July 2014

fn1 = 'booldata1.mat';
fn2 = 'booldata2.mat';

camshift = [0,12]; %amount of time indices per camera to shift to correct for initial (and hopefully constant!) time offset
%% load data
load(fn1)
load(fn2)

%cells allow for unequal number of rows (time), since we don't start/stop the cameras at the same instants
bd{1} = booldata1; 
bd{2} = booldata2;

Nbool = size(booldata1,2);
Ncam = length(bd);

%% implement time shift
% we "time shift" by throwing away first data elements from camera you want to
% shift "back" in time!
for icam = 1:Ncam
   bd{icam} = bd{icam}(camshift(icam)+1:end,:);  %sigh, one-indexing requires +1 
end
%% do plotting
figure(1),clf(1)
clr = ['b','r'];
for icam = 1:Ncam
    for iled = 1:Nbool
        subplot(2,2,iled,'nextplot','add')
        plot(bd{icam}(:,iled),'color',clr(icam),'displayname',['cam',int2str(icam)])%,', led',int2str(iled)])
    end
end

%% label the plots (just once to avoid weird text overlap)
for iled = 1:Nbool
   subplot(2,2,iled)
   xlabel('sample index')
   ylabel('LED pixel boolean')
   legend('show')
   title(['LED #',int2str(iled)])
   %set(gca,'xlim',[50,150])
end
end