%% COMPARE RAW 1P/ RAW 2P/ THORSYNC DIRECTORIES
directory_lists= get.directories(551,'DRGS') ;


%% CHECK FILES

%% LOAD FALL.MAT (OPTIONAL)

load('/Volumes/Warwick/DRGS/#551/SDH/Functional/Split/suite2p/combined/Fall.mat')
%% COMPRESS THORSYNC 
[tsync] = utils.compress_tsync(550,'DRGS','Warwick'); 

%% SAVE 
avgmovie=[]; deleted_folders=[]; dsnum = 550; 
utils.save_Experiment_Verification(dsnum,tsync,deleted_folders,avgmovie,directory_lists); 



