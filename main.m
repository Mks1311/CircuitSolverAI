% Main function to detect components in a circuit image
function detectComponents()
    % Display welcome message
    disp('Welcome to the Circuit Component Detection Program!');
    disp('This system uses AI to detect Transistors, Diodes, LEDs, and Photodiodes in circuit diagrams.');

    % Prompt the user for the circuit image file
    circuitImgFile = input('Please enter the filename of the circuit image (with extension): ', 's');
    if isempty(circuitImgFile)
        circuitImgFile = 'circuit_image.jpg';  % Default circuit image
    end

    % Load the circuit image
    circuitImg = imread(circuitImgFile);
    figure, imshow(circuitImg), title('Original Circuit Image');
    
    % Preprocess the image (convert to grayscale, contrast adjustment, and edge detection)
    grayCircuit = preprocessImage(circuitImg);
    
    % Prompt the user to select the component to detect
    disp('Which component would you like to detect?');
    disp('1: Transistor');
    disp('2: Diode');
    disp('3: LED');
    disp('4: Photodiode');
    disp('5: Detect All');
    choice = input('Please enter your choice (1-5): ');
    
    % List of component templates and names
    componentList = {'transistor_template.jpg', 'diode_template.jpg', 'led_template.jpg', 'photodiode_template.jpg'};
    componentNames = {'Transistor', 'Diode', 'LED', 'Photodiode'};
    
    % Loop through each component template based on user choice
    switch choice
        case 1
            detectComponent(grayCircuit, componentList{1}, componentNames{1});
        case 2
            detectComponent(grayCircuit, componentList{2}, componentNames{2});
        case 3
            detectComponent(grayCircuit, componentList{3}, componentNames{3});
        case 4
            detectComponent(grayCircuit, componentList{4}, componentNames{4});
        case 5
            for i = 1:length(componentList)
                detectComponent(grayCircuit, componentList{i}, componentNames{i});
            end
        otherwise
            disp('Invalid choice. Exiting.');
            return;
    end
end

% Function to preprocess the circuit image
function grayImg = preprocessImage(img)
    disp('Preprocessing the circuit image...');
    
    % Convert to grayscale
    grayImg = rgb2gray(img);
    disp('Converted to grayscale.');
    
    % Apply contrast enhancement to improve edge visibility
    grayImg = imadjust(grayImg);
    disp('Contrast enhanced.');
    
    % Apply median filtering to remove noise
    grayImg = medfilt2(grayImg);
    disp('Noise removed with median filtering.');
    
    % Optional: Apply morphological operations to enhance the structure
    se = strel('line', 3, 0);
    grayImg = imdilate(grayImg, se);
    disp('Morphological dilation applied.');

    % Show the preprocessed image
    figure, imshow(grayImg), title('Preprocessed Circuit Image');
    
    % Return preprocessed image
    disp('Preprocessing complete.');
end

% Function to detect a specific component in the circuit image
function detectComponent(grayCircuit, templateFileName, componentName)
    disp(['Detecting ', componentName, '...']);
    
    % Load the template image for the component
    templateImg = imread(templateFileName);
    
    % Preprocess the template image (convert to grayscale, enhance, and edge detection)
    grayTemplate = preprocessTemplate(templateImg);
    
    % Perform edge detection on the circuit image
    circuitEdges = edge(grayCircuit, 'Canny');
    
    % Optional: Try different rotation angles for the template
    angles = 0:30:180;  % Testing rotations at intervals of 30 degrees
    maxCorrelation = -Inf;
    bestAngle = 0;
    for angle = angles
        rotatedTemplate = imrotate(grayTemplate, angle, 'crop');
        % Perform edge detection on the rotated template
        rotatedEdges = edge(rotatedTemplate, 'Canny');
        
        % Perform template matching using normalized cross-correlation
        correlationOutput = normxcorr2(rotatedEdges, circuitEdges);
        
        % Check if this rotation gives a better match
        maxVal = max(correlationOutput(:));
        if maxVal > maxCorrelation
            maxCorrelation = maxVal;
            bestAngle = angle;
        end
    end
    
    % Load the best matching template
    bestTemplate = imrotate(grayTemplate, bestAngle, 'crop');
    
    % Perform template matching again using the best angle
    bestTemplateEdges = edge(bestTemplate, 'Canny');
    correlationOutput = normxcorr2(bestTemplateEdges, circuitEdges);
    
    % Find the peak of the correlation output
    [ypeak, xpeak] = find(correlationOutput == max(correlationOutput(:)));
    
    % Get the size of the template for positioning
    [templateHeight, templateWidth] = size(bestTemplateEdges);
    
    % Calculate the location of the detected component
    yoffSet = ypeak - templateHeight;
    xoffSet = xpeak - templateWidth;
    
    % Display the original circuit image with the detected component marked
    figure;
    imshow(imread('circuit_image.jpg'));  % Reload the original image for display
    title(['Detected ', componentName, ' at angle ', num2str(bestAngle)]);
    hold on;
    
    % Draw a rectangle around the detected component
    rectangle('Position', [xoffSet, yoffSet, templateWidth, templateHeight], ...
              'EdgeColor', 'r', 'LineWidth', 3);
    hold off;
    
    disp([componentName, ' detected and displayed on the image.']);
end

% Function to preprocess the template image
function grayTemplate = preprocessTemplate(templateImg)
    disp('Preprocessing the component template...');
    
    % Convert to grayscale
    grayTemplate = rgb2gray(templateImg);
    
    % Apply contrast adjustment
    grayTemplate = imadjust(grayTemplate);
    disp('Template contrast adjusted.');
    
    % Apply edge detection
    grayTemplate = edge(grayTemplate, 'Canny');
    disp('Template edge detection complete.');
    
    % Return preprocessed template
    disp('Template preprocessing complete.');
end
