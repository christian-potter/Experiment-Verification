function[tlh5]= read_h5(filename)
%% DESCRIPTION 
% takes name of h5 file from one of the thorsync acquisition sessions and
% returns table with appropriate variables 

%% NOTES
% ** need to verify new channel names post new computer 


%% READ H5 FILE 
% if error, use h5disp(folder) to determine what names actually are 

try 
    estim = h5read(filename,'//AI/E_Stim'); 
catch
    estim = h5read(filename,'//AI/Estim');
end

try 
    mforce = h5read(filename,'//AI/M_Force'); 
catch 
    mforce = h5read(filename,'//AI/Force'); 
end

try 
    mlength = h5read(filename,'//AI/M_Length'); 
catch 
    mlength= h5read(filename,'//AI/Length'); 
end


pedal = h5read(filename,'//AI/Pedal');

try 
    peltier = h5read(filename,'//AI/Pelt_Temp');
catch 
    peltier =  h5read(filename,'//AI/Temp'); 
end 

piezo = h5read(filename,'//AI/PiezoMonitor');
try 
    pockels= h5read(filename,'//AI/PockelsMonitor');
catch 
    pockels = h5read(filename,'//AI/Pockels1Monitor'); 
end


framecount = h5read(filename,'//CI/FrameCounter');

try 
    frames =h5read(filename,'//DI/2pFrames');
catch 
    frames =h5read(filename,'//DI/FrameIn');
end



%captureactive = h5read(folder,'//DI/CaptureActive');
%pandaframes = h5read(folder,'//DI/PandaFrames');

%fithz = h5read(folder,'//Freq/FitHz');%also all zeros 
%hz = h5read(folder,'//Freq/Hz'); %all zeros for some reason 

%gctr = h5read(folder,'//Global/GCtr');

%% MAKE TABLE, NAME VARIABLES

tlh5= table(estim',mforce',mlength',pedal',peltier',piezo',pockels',framecount',frames'); %; ,captureactive',pandaframes',gctr'); 

tlh5.Properties.VariableNames={'estim','mforce','mlength','pedal','peltier','piezo','pockels','framecount','frames'};%,'captureactive','pandaframes','gctr'}; 


%% TO ADD TO THIS FUNCTION 
% CHECK VARIABLES/ INFO IN THE XML 
% 
% thorsync_xml = importxml('/Volumes/Potter/#518/Final FOV/ThorSync/TS_SDH#518/ThorRealTimeDataSettings.xml'); 

% only thing I can think to add is if enable =1 for khz = 30k 