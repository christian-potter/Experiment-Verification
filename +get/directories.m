function [folder_list] = directories(dsnum) 
dsnum = num2str(dsnum); 

if ismac
    base = ['/Volumes/Warwick/DRGS project/#',dsnum,'/']; 
elseif ispc
    base = ['\\Shadowfax\Warwick\DRGS project\#',dsnum,'\']; 
end

d{1} = dir([base,'/DRG/1p/Functional/Raw/']);
d{2} = dir([base,'/SDH/Functional/Raw/']); 

d{3}= dir([base,'/SDH/Functional/ThorSync/']); 



folder_names = {'direct1p','direct2p','directtsync'}; 

%folder_list = struct('1p',[],'2p',[],'tsync',[]); 

%% 

for f = 1:length(folder_names)
    count = 0; 
    direct = d{f}; 
    for i = 1:length(direct)
        if contains(direct(i).name,'#')|| contains(direct(i).name,'2025')
            count = count+1; 
            folder_list(count).(folder_names{f}) = direct(i).name; 
        end
    end

end

