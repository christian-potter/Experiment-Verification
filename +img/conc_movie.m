function [movie] = conc_movie(concimg,imdata,nplanes)

arguments 
    concimg double % size of concatenated image
    imdata double% Y x X matrix 
    nplanes double % sets length of iter 
end

%% DESCRIPTION
% imdata is a sequence of images for each plane and color (r/g). conc_movie
% assembles this into a movie 

% 
% %% ASSEMBLE MOVIE 
% iter = nplanes*2;
% nframes = size(imdata,3)/iter; 
% movie = zeros(size(imdata,1),size(imdata,2),3,nframes); 
% 
% 
% for f = 1:size(imdata,3)/ iter % for each frame in time of movie 
%     imdata_count = 0; 
% 
%     for p = 1:nplanes
%         [r,c] = img.select_quadrant(concimg,p); 
% 
%         for color = 1:2
%             imdata_count = imdata_count+1; 
%             if color == 1% 2 colors for each plane
% 
%                 quadrant=imdata(:,:,imdata_count); 
%                 movie(r,c,f)=quadrant;
%             end
% 
% 
%         end
%     end
% 
% 
% end

%% ASSEMBLE MOVIE 
iter = nplanes*2;
nframes = size(imdata,3)/iter; 
movie = zeros(size(imdata,1),size(imdata,2),3,nframes); 

for f = 1:size(imdata,3)/ iter % for each frame in time of movie 
    imdata_count = 0; 

    for p = 1:nplanes
        [r,c] = img.select_quadrant(concimg,p); 
        
        for color = 1:2
            imdata_count = imdata_count+1; 
            %if color == 1% 2 colors for each plane
                quadrant=imdata(:,:,imdata_count); 
                movie(r,c,color,f)=quadrant;
            %end
        end
    end


end