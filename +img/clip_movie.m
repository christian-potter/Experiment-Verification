function [clipped_movie] = clip_movie(delete_tseries,tslist,avgmovie)
arguments
    delete_tseries double % vector with tseries to remove ** need to change to individual splits
    tslist double % contains index of where ts folders appear in movie 
    avgmovie double 
end

delete_vect = tslist == delete_tseries; 

avgmovie(:,:,delete_vect)=[] ; 


end


