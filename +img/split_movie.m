function [avgmovie] =split_movie(nplanes,yx,dsnum)
arguments
    nplanes double % scalar for number of planes (only 4 works)
    yx double % 2D vector with 
    % ** rows x cols, so yx 
    dsnum double % dataset number 
end


%% DESCRIPTION
% calls conc_movie to concatenate all imaged planes together from red and
% green channel for each .tif from stack splitter

% CTP - 1/29/26

%% NOTES
% * add pixels for the exact split subfolder
% * make work for different number of pl;anes 
%% GET FOLDER
dsnum = num2str(dsnum); 
if ismac
    folder = ['/Volumes/Warwick/DRGS project/',dsnum,'/SDH/Functional/Split'];
elseif ispc
    folder = ['\\Shadowfax\Warwick\DRGS project\',dsnum,'\SDH\Functional\Split'];
end
direct = dir(folder); 
%% MAKE VARIABLES 
yx = nan(yx(1),yx(2)); 

if nplanes == 4
    concimg = [yx,yx;yx,yx]; 
else
    disp('unsupported number of planes')
end

ts_frames = 5; 
avgmovie = nan(size(concimg,1),size(concimg,2),3,length(direct)); 
tscount = 0;
%% COMBINE TSERIES
for i =1:length(direct)
    if contains(direct(i).name,'.tif') % if file is a .tif
        tsnum = str2double(direct(i).name(6:8)); 

        tif_file = [direct(i).folder,'/',direct(i).name]; 
        imdata= bigread4(tif_file);
        
        movie = img.conc_movie(concimg,imdata,nplanes); 

        avgts = img.average_movie(movie,ts_frames,tsnum); 
        avgmovie(:,:,:,i) = avgts; 
    end
end