function [tsync] = compress_tsync(dsnum,project,user)
arguments
    dsnum double
    project char
    user char
end

%% DESCRIPTION 
% function that receives directory of thorsync folders, iterates through
% folders, averages tsync such that there is only one row per frame 

% CTP- 11-27-2025

%% GET FOLDER DIRECTORY
if ismac 
    pathname = ['/Volumes/Warwick/DRGS project/#550/SDH/Functional/ThorSync']; 
end

% get directory and then return to original folder 
rf = cd; 
cd(pathname)
direct = dir; 
cd(rf)

%% CHECK DIRECT IS IN APPROPRIATE ORDER, .name contains "TS"
ts_start=0;
count = 1; 
for d = 1:length(direct)
    if contains(direct(d).name,'TS')
        filename = [direct(d).folder,'/',direct(d).name,'/Episode_0000.h5']; 
        disp(['Processing ', filename])
        [ntsync]= md.read_h5(filename);
        ntsync = utils.averageByFramecount(ntsync,6); 
        ntsync.tseries = ones(size(ntsync,1),1)*count; 
        if ts_start ==0
            tsync = ntsync; 
            ts_start=1; 
        elseif ts_start ==1
            tsync=[tsync;ntsync]; 
        end
        count = count+1; 
        disp('Completed')
    end
end

% %% FIND FRAMES WHERE NEW TSERIES BEGINS 
% tseries_breaks=find(diff(tsync.tseries)==1);
% figure
% hold on 
% plot(tsync.peltier)
% plot(tsync.mforce)
% xline(tseries_breaks)
% utils.sf
% 
% %% PLOT TSERIES BREAKS TO VERIFY 
% tseries_breaks=find(diff(tsync.tseries)==1);
% figure
% plot(tsync.mforce)
% hold on 
% plot(mean(dF_F,1))
% xline(tseries_breaks)
% xline(find(ops.badframes==1),'color','r')


