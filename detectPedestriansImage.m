frame = imread('pedsFrame.png');

%% Pedestrian detection specific parameters
% Set up People Detector
peopleDetector = vision.PeopleDetector(...
    'UprightPeople_96x48',... 
    'WindowStride',[9 9],...  % increasing improves performance, decreases accuracy
    'ClassificationThreshold',1,... % increase to reduce false detections
    'MaxSize', [97 49],... % knowing the max size improves performance
    'UseROI', 1); % knowing region of interest improves performance
% MODIFY all of the above parameters for accuracy

 %% Detect people using the people detector object
    % calculate region of interest
    [nr, nc, ~] = size(frame);
    roi = [1 1/3*nr nc 0.4*nr];
    
    bounds = [1 1 nc 1/3*nr; 1 (0.4+1/3)*nr nc (1-(0.4+1/3))*nr];
    insertedFrame = insertShape(frame, 'FilledRectangle', bounds, 'Color', 'black', 'Opacity', 0.5);
    insertedFrame = insertShape(insertedFrame, 'Rectangle', roi, 'Color', 'red');
    
    bboxes = step(peopleDetector,frame, roi);
    
    
    %% Overlay detected people
frameOut = insertShape(insertedFrame,'rectangle',bboxes);
imshow(frameOut)
    