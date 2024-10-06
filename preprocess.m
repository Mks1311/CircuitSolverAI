% preprocess.m

function processedImage = preprocessImage(inputImage)
    % Convert the image to grayscale
    grayImage = rgb2gray(inputImage);
    
    % Resize the image for consistent processing
    resizedImage = imresize(grayImage, [256 256]);
    
    % Apply Gaussian filter for noise reduction
    filteredImage = imgaussfilt(resizedImage, 2);
    
    % Thresholding to create a binary image
    binaryImage = imbinarize(filteredImage);
    
    % Invert binary image for detection purposes
    processedImage = imcomplement(binaryImage);
    
    % Display the processed image (optional)
    figure;
    subplot(1, 2, 1), imshow(inputImage), title('Original Image');
    subplot(1, 2, 2), imshow(processedImage), title('Processed Image');
end
