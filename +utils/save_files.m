function [] = save_files(dsnum,project,user,variable_list,varargin)

%    dsnum double 
 %   project string 
  %  user string 
   % variable_list cell 
    %varargin 



%% DESCRIPTION 
% Function used by data_organization script to save variables to the
% processed_data folder 

% all entered variables should go at the end and correspond to the order
% entered in variable_list 



%% CREATE SAVE PATH 

if ismac 
    save_path = ['/Volumes/',user,'/',project,'/',num2str(dsnum)]; 
else
    save_path=[];
    disp('Windows File Path Not Specified')
end


%% SAVE VARIABLES TO FILE 

if length(varargin)==length(variable_list)
    for v = 1:length(variable_list)
        save(variable_list{v},[save_path,'/',variable_list{v}])
    end

else 
    disp('Entered Variables Must be Same Number as Entered in variable_list')
end


end