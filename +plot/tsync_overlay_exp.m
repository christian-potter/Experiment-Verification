function [] = tsync_overlay_exp(tsync,dff,dsnum,opt)
arguments
    tsync table % entire table 
    dff double % entire dff 
    dsnum double % number of the dataset
    opt.drgs logical = false ; 
end
%% DESCRIPTION 
% plots the main overlay for validating that tsync file is properly aligned
% with the dff 


% - Updated CTP 11-28-2025
%% CREATE VARIABLES
tseries_frames = get.tseries_frames(tsync); 
tseries_frames(tseries_frames==0)=[]; 
tseries_frames= cumsum(tseries_frames); 
baseline= mode(tsync.peltier); % take most common number in the peltier signal as the baseline 

%% PLOT 

figure
hold on 
plot(mean(dff,1,'omitnan'))

plot(tsync.estim)
plot(tsync.peltier)
plot(tsync.mforce)
plot(tsync.pedal)
legend({'dff','estim','peltier','mforce','pedal'})
%- INCLUDE DRGS 
% elseif strcmp(opt.drgs,'drgs')
%     plot(tsync.estim)
%     legend({'dff','estim'})
% end


%- plot tseries boundaries 
%xline(tseries_frames,'HandleVisibility','off')
for i =1:length(tseries_frames)
    %text (tseries_frames(i)+20,baseline,num2str(i),'color','r'); 
end
%- figure labeling 

utils.sf 
xlabel('Frames')
title({'Aligned Thorsync + Mean dF/F',['#',num2str(dsnum)]})
