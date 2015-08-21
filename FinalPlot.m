function [DataPoints] = FinalPlot(fn,frameReq,NumLED,prowcol,t,hMain,iCam,showProgress) 

axs = makeplots(NumLED,prowcol);
lc = ['b','r','m'];

set(2,'name',fn)

nFrame = length(frameReq);
disp(['plotting ',int2str(nFrame),' time steps'])

DataPoints = NaN(nFrame,length(NumLED)); %pre-allocate

jFrm = 1;
for iFrm = frameReq
    ImageData = readFrame(fn,iFrm); %read current image from disk
    if showProgress  
     set(hMain.img,'cData',ImageData) %update picture
    end
    
    jLED = 1;
    for iLED = NumLED
        DataPoints(jFrm,jLED) = ImageData(prowcol(iLED,1),prowcol(iLED,2)); %pull out the data number for this LED for this frame
        if showProgress
            plot(axs(jLED),t,DataPoints(:,jLED),'color',lc(iCam));  % % this updates the plot lines with current LED data
        end
        jLED = jLED+1;
    end
    if showProgress
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

function axs = makeplots(NumLED,prowcol)

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
    title(axs(j),['Data at Row/Col #',int2str(prowcol(j,:)),' LED #',int2str(j)])
    %xlabel('Frame #','fontsize',14)
    xlabel('Time (sec)','fontsize',14)
    ylabel('Data Number','fontsize',14)

jj = jj+1;
end

end