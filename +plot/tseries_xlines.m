function [] = tseries_xlines(tseries_frames,opt)
arguments 
    tseries_frames double % vector with the number of frames in each tseries
    opt.text_numbers logical = true  
end
%% DESCRIPTION 
% plots t-series xlines with text over already existing figure 


%% PLOT XLINES 
xline(cumsum(tseries_frames),'HandleVisibility','off')

%% PLOT TEXT 
if opt.text_numbers
    ctseries_frames = cumsum(tseries_frames); 
    ctseries_frames=[0;ctseries_frames]; 
    for i = 1:length(tseries_frames)
        text(ctseries_frames(i)+300,3,num2str(i),'color','r','FontSize',15)
    end
end


%%