function [r,c,quadrant] = select_quadrant(array, position)
arguments
    array double 
    position double % number 1-4 indicating quadrant position counter-clockwise
end
%% DESCRIPTION
% generates r and c indices for locations of quadrant in an array of
% size(array)
  
%%
% Determine the size of the array
[rows, cols] = size(array);

% Initialize the logical array with false values
quadrant = false(rows, cols);
r = false(1,rows); c = false(1,cols); 
% Select quadrant based on position
switch position
    case 1 % top-left
        quadrant(1:rows/2, 1:cols/2) = true;
        r(1:rows/2)=true; 
        c(1:cols/2)=true;
    case 2 % top-right
        quadrant(1:rows/2, cols/2:cols) = true;
        r(1:rows/2)=true; 
        c(cols/2+1:cols)=true; 
    case 3 % bottom-right
        quadrant(rows/2:rows, cols/2:cols) = true;
        r(rows/2+1:rows)=true; 
        c(cols/2+1:cols)=true; 
    case 4 % bottom-left
        quadrant(rows/2:rows, 1:cols/2) = true;
        r(rows/2+1:rows)=true; 
        c(1:cols/2)=true;
    otherwise
        error('Invalid position. Use 1 for top-left, 2 for top-right, 3 for bottom-right, or 4 for bottom-left.');
end

    
   
end