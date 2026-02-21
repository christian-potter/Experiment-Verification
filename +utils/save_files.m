function [] = save_experiment_verification(dsnum,project,user,tseries_md,zstack,zstack_md)
%% NOTES
%* need to add full list of variables 

%% DESCRIPTION 
% Function used by data_organization script to save variables to the
% processed_data folder 

% all entered variables should go at the end and correspond to the order
% entered in variable_list 

%% DEFINE ORDER OF VARIABLES

%variable_list={'tseries_frames','ref','tsync','zstack','zstack_md','tseries_md'}; 
variable_list = {'tseries_md','zstack','zstack_md'};


%% CREATE SAVE PATH 

if ismac 
    save_path = ['/Volumes/',user,'/',project,'/#',num2str(dsnum)]; 
else
    save_path=[];
    disp('Windows File Path Not Specified')
end


%% SAVE VARIABLES TO FILE 

%  this is actually for data_organization 

% save([save_path,'/',variable_list{1}],"tseries_md")
% save([save_path,'/',variable_list{2}],"zstack")
% save([save_path,'/',variable_list{3}],"zstack_md")
% 


end