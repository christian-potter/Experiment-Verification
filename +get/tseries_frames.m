function [tseries_frames] = tseries_frames(tsync)
arguments 
    tsync table % compressed tsync to each frame 
end


%% NOTES
% function that returns the frames calculated for each tseries using
% thorsync metadata 

dframecount = diff(tsync.framecount); 
x = find(dframecount~=1); 

y = tsync.framecount(x); 
tseries_frames=[y;tsync.framecount(end)]; % add the last tseries on 

%%

