function [adjmovie] = adjust_movie(brightness_factor,contrast_factor,avgmovie)
%%
arguments
    brightness_factor double % Factor to increase brightness (1 for no change)
    contrast_factor double    % Factor to increase contrast (1 for no change)
    avgmovie double % movie to be adjusted
end
%% DESCRIPTION
% 

%% NOTES 
%* currently does not affect .tif much. need to understand MovieViewer to
% understand why 

%% DELETE BLANK FRAMES 
delete_vect = false(1,size(avgmovie,3)); 

for l = 1:size(avgmovie,3)
    if isnan(avgmovie(1,1,l))
        delete_vect(l)=true; 
    end
end
avgmovie(:,:,delete_vect)=[]; 
disp(['Deleted Directory Folders:',num2str(find(delete_vect))])
%% ADJUST BRIGHTNESS AND CONTRAST OF MOVIE

% for m = 1:size(avgmovie, 3)
%     for x = 1:size(avgmovie, 1)
%         for y = 1:size(avgmovie, 2)
%             % Adjust brightness
%             adjmovie(x, y, m) = avgmovie(x, y, m) * brightness_factor;
%             % Adjust contrast
%             adjmovie(x, y, m) = ((avgmovie(x, y, m) - 0.5) * contrast_factor) + 0.5;
%             % % Clip values to be in the valid range [0, 1]
%             % avgmovie(x, y, m) = min(max(avgmovie(x, y, m), 0), 1);
%         end
%     end
% end

for f = 1:size(avgmovie, 4)
    for m = 1:size(avgmovie, 3)
        for x = 1:size(avgmovie, 1)
            for y = 1:size(avgmovie, 2)
                % Adjust brightness
                adjmovie(x, y, m, f) = avgmovie(x, y, m, f) * brightness_factor;
                % Adjust contrast
                adjmovie(x, y, m, f) = ((adjmovie(x, y, m, f) - 0.5) * contrast_factor) + 0.5;
                % Clip values to be in the valid range [0, 1]
                %adjmovie(x, y, m, f) = min(max(adjmovie(x, y, m, f), 0), 1);
            end
        end
    end
end