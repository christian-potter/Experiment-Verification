function numbered_image = addNumberShape(inputImage, number)
    % % Validate input dimensions
    % [xpix, ypix] = size(inputImage);
    % 
    % % Check if the input image is grayscale
    % if ndims(inputImage) ~= 2
    %     error('Input image must be a grayscale image.');
    % end
    % 
    % % Create a blank image to draw the number
    % numbered_image = inputImage;
    % 
    % % Define the shape of the number using a binary mask
    % % For simplicity, we will use a predefined mask for numbers 0-9
    % numberMasks = img.digit_masks();
    % % Check if the number is valid
    % if number < 0 || number > 99
    %     error('Number must be between 0 and 99.');
    % end
    % 
    % % Convert number to string to handle multiple digits
    % numberStr = num2str(number);
    % numDigits = length(numberStr);
    % 
    % % Calculate the starting position for the first digit
    % startX = floor((xpix - 4) / 2); % Center vertically
    % startY = floor((ypix - (numDigits * 4)) / 2); % Center horizontally based on number of digits
    % 
    % % Add each digit to the output image
    % for d = 1:numDigits
    %     digit = str2double(numberStr(d)); % Get the current digit
    %     numberMask = numberMasks{digit + 1}; % +1 for 1-based indexing
    % 
    %     % Determine the size of the number mask
    %     [maskHeight, maskWidth] = size(numberMask);
    % 
    %     % Calculate the position to place the current digit
    %     currentStartY = startY + (d - 1) * (maskWidth + 1); % Offset for each digit
    % 
    %     % Add the number shape to the output image
    %     for i = 1:maskHeight
    %         for j = 1:maskWidth
    %             if numberMask(i, j) == 1
    %                 numbered_image(startX + i, currentStartY + j) = 255; % White color for the number in grayscale
    %             end
    %         end
    %     end
    % end


    % Validate input dimensions
    [xpix, ypix, numChannels] = size(inputImage);
    
    % Check if the input image is RGB
    if numChannels ~= 3
        error('Input image must be an RGB image.');
    end
    
    % Create a blank image to draw the number
    numbered_image = inputImage;
    
    % Define the shape of the number using a binary mask
    % For simplicity, we will use a predefined mask for numbers 0-9
    numberMasks = img.digit_masks();
    % Check if the number is valid
    if number < 0 || number > 99
        error('Number must be between 0 and 99.');
    end
    
    % Convert number to string to handle multiple digits
    numberStr = num2str(number);
    numDigits = length(numberStr);
    
    % Calculate the starting position for the first digit
    startX = floor((xpix - 4) / 2); % Center vertically
    startY = floor((ypix - (numDigits * 4)) / 2); % Center horizontally based on number of digits
    
    % Add each digit to the output image
    for d = 1:numDigits
        digit = str2double(numberStr(d)); % Get the current digit
        numberMask = numberMasks{digit + 1}; % +1 for 1-based indexing
        
        % Determine the size of the number mask
        [maskHeight, maskWidth] = size(numberMask);
        
        % Calculate the position to place the current digit
        currentStartY = startY + (d - 1) * (maskWidth + 1); % Offset for each digit
        
        % Add the number shape to the output image
        for i = 1:maskHeight
            for j = 1:maskWidth
                if numberMask(i, j) == 1
                    numbered_image(startX + i, currentStartY + j, :) = 255; % White color for the number in RGB
                end
            end
        end
    end
end