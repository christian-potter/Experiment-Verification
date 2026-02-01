function [] = save_Experiment_Verification(dsnum,tsync,deleted_folders,avgmovie,folder_list)

%% 
dsnum = num2str(dsnum); 


if ismac
    base = ['/Volumes/Warwick/DRGS project/#',dsnum,'/SDH/Processed/']; 
elseif ispc
    base = ['\\Shadowfax\Warwick\DRGS project\#',dsnum,'\SDH\Processed\']; 
end


save([base,'tsync.mat'],'tsync')
save([base,'deleted_folder.mat'],'deleted_folders')
save([base,'avgmovie.mat'],'avgmovie')
save([base,'folder_list.mat'],'folder_list')




save([base,''])


%%
 


generate_suite2p_ops_matlab('data_path', "/data/exp01/sessionA", ...
    'save_path0', "/data/exp01/processed", ...
    'fs', 30, ...
    'nplanes', 1, ...
    'nchannels', 2, ...
    'functional_chan', 1, ...
    'tau', 1.0, ...
    'extra_ops', struct( ...
        'do_registration', true, ...
        'batch_size', 2000 ...
    ), ...
    'write_db', true, ...
    'out_db_npy', "db.npy");