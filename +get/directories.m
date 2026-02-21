function [directory_lists] = directories(dsnum,project) 
dsnum = num2str(dsnum); 

if ismac
    base = ['/Volumes/Warwick/',project,'/#',dsnum,'/']; 
elseif ispc
    base = ['\\Shadowfax\Warwick\',project,'\#',dsnum,'\']; 
end

%% FOLDERS TO GET DIRECTORIES FROM 
d{1} = dir([base,'/DRG/1p/Functional/Raw/']);
d{2} = dir([base,'/SDH/Functional/Raw/']); 
d{3}= dir([base,'/SDH/Functional/ThorSync/']); 



folder_names = {'direct1p','direct2p','directtsync'}; 

%folder_list = struct('1p',[],'2p',[],'tsync',[]); 

%% CREATE FOLDER_LIST

for f = 1:length(folder_names)
    count = 0; 
    direct = d{f}; 
    if isempty(direct)
        disp(['Folder Not Found'])
    end

    for i = 1:length(direct)
        if contains(direct(i).name,'#')|| contains(direct(i).name,'2025')
            count = count+1; 
            directory_lists(count).(folder_names{f}) = direct(i).name; 
        end
    end

end

