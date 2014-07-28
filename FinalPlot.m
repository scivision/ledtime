function [axs,DataPoints] = FinalPlot(fn,frameReq,NumLED,pCol,pRow,t,hMain,axs,iCam,doflipud) 

showProgress = true;

global firstrun
if firstrun
    axs = makeplots(NumLED,pCol,pRow);
    firstrun = false;
end
lc = ['b','r','m'];

[~,~,ext] = fileparts(fn);
set(2,'name',fn)

nFrame = length(frameReq) %#ok<NOPRT>

DataPoints = NaN(nFrame,length(NumLED)); %pre-allocate

jFrm = 1;
for iFrm = frameReq
    ImageData = readFrame(fn,ext,iFrm,doflipud); %read current image from disk
    if showProgress  
     set(hMain.img,'cData',ImageData) %#ok<*UNRCH> %update picture
    end
    
    jLED = 1;
    for iLED = NumLED
        DataPoints(jFrm,jLED) = ImageData(pRow(iLED),pCol(iLED)); %pull out the data number for this LED for this frame
        if showProgress
            plot(axs(jLED),t,DataPoints(:,jLED),'color',lc(iCam));  % % this updates the plot lines with current LED data
        end
        jLED = jLED+1;
    end
    if showProgress,  
        pause(0.01) 
    elseif ~mod(jFrm,50)
        display(['frame #',int2str(iFrm),',  ',num2str(jFrm/nFrame*100,'%0.1f'),' % complete'])
    end
    jFrm = jFrm+1;
end

if ~showProgress %plot just once at the end
       jLED = 1;
    for iLED = NumLED
         plot(axs(jLED),t,DataPoints(:,jLED),'color',lc(iCam));  % this updates the plot lines with current LED data
         jLED = jLED+1;
    end
end


end %function

function axs = makeplots(NumLED,pCol,pRow)

figure(2)
set(2,'pos',[100,30,1000,700])
jj=1;
for j=NumLED  
    if length(NumLED) > 1
            if length(NumLED)<5
                sprc = 2;
            else
                sprc = 3;
            end
        axs(j) = subplot(sprc,sprc,jj,'parent',2);  %#ok<AGROW>
    else
        j = 1; %#ok<FXSET>
        axs = axes('parent',2); 
    end
    
    set(axs(j),'nextplot','add')
    title(axs(j),['Data at Column #',int2str(pCol(j)),' Row #',int2str(pRow(j)),' LED #',int2str(j)])
    %xlabel('Frame #','fontsize',14)
    xlabel('Time (sec)','fontsize',14)
    ylabel('Data Number','fontsize',14)

jj = jj+1;
end

end