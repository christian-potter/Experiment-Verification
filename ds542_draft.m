figure
hold on 
plot(f)
plot(tsync.estim)
plot(tsync.peltier)
plot(tsync.mforce)
plot(tsync.pedal)



%%
plot.tsync_overlay(tsync,f,542)

figure;
plot(cumsum(tseries_frames))
hold on; 
plot(cumsum(folder_tseries_frames))

%%
x = cumsum(folder_tseries_frames); 
blank_ts= tsync(1:x(5),:); 

blank_ts{:,:} = 0;


ntsync = [blank_ts;tsync]; 
%%
plot.tsync_overlay_exp(ntsync,f,542)

%%
filename = '/Volumes/Ross/Warwick/4TB Drive Transfer/#542 3-25-25/Final FOV/#542_001/Experiment.xml'; 
Experiment = md.importxml(filename); 
[tseries_md] = md.extract_metadata(Experiment); 