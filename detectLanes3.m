function [lineStruct, Rep_ref, Count_ref, NumNormalDriving, OutMsg, leftTheta, rightTheta] = ...
    detectLanes3(frame, Rep_ref, Count_ref, NumRows, TrackThreshold, ...
    NumNormalDriving,OutMsg,ExpLaneNum,MaxLaneNum,frameFound,frameLost, ...
    lanesOn)

if lanesOn
    %% Lane Departure Warning System
    % This example shows how to detect road lane markers in a video stream and how to highlight the
    % lane in which the vehicle is driven. This information can be used to
    % detect an unintended departure from the lane and issue a warning.

    % Copyright 2004-2014 The MathWorks, Inc.

    %% Introduction
    % This example detects and tracks road lane markers in a video sequence and
    % notifies the driver if they are moving across a lane. The example
    % illustrates how to use the |HoughTransform|, |HoughLines| and
    % |LocalMaximaFinder| System objects to create line detection and tracking
    % algorithms. The example implements this algorithm using the following steps:
    %
    % # Detect lane markers in the current video frame.
    % # Match the current lane markers with those detected in the previous video frame.
    % # Find the left and right lane markers.
    % # Issue a warning message if the vehicle moves across either of the lane markers.

    %%
    % To process low quality video sequences, where lane markers might be
    % difficult to see or are hidden behind objects, the example waits for a lane
    % marker to appear in multiple frames before it considers the marker to be
    % valid. The example uses the same process to decide when to begin to ignore a
    % lane marker.

    %% Initialization
    % Use these next sections of code to initialize the required variables and
    % System objects.

    % Offset for displaying the lines
    offset = int32([0, NumRows, 0, NumRows]);

    %%
    % Create |HoughLines| System objects to find the Cartesian coordinates of
    % the lines defined by the lane markers.
    hHoughLines1 = vision.HoughLines('SineComputation', 'Trigonometric function');

    %% Stream Processing Loop

        RGB = frame;

        % Select the lower portion of input video (confine field of view)
        Imlow  = RGB(NumRows+1:end, :, :);

        %% Edge detection and Hough transform
        Imlow = rgb2gray(Imlow); % Convert RGB to intensity

        I = imfilter(Imlow, [-1 0 1], 'replicate','corr');

        % Saturate the values to be between 0 and 1
        I(I < 0) = 0;
        I(I > 1) = 1;

        th = multithresh(I); % compute threshold
        [H, Theta, Rho] = hough(I > th);

        % Convert Theta to radians
        Theta = Theta * pi / 180;

        % Peak detection
        H1 = H;
        % Wipe out H matrix with theta < -78 deg and theta >= 78 deg
        H1(:, 1:12) = 0;
        H1(:, end-12:end) = 0;
        Idx1 = houghpeaks(H1, ExpLaneNum, 'NHoodSize', [301 81], 'Threshold', 1); % [rho1 theta1; rho2 theta2]
        Count1 = size(Idx1,1);

        % Select Rhos and Thetas corresponding to peaks
        Line = [Rho(Idx1(:, 1)); Theta(Idx1(:, 2))]; % [peakRho1 peakRho2; peakTheta1 peakTheta2]
        Enable = [ones(1,Count1) zeros(1, ExpLaneNum-Count1)]; % [1 1] if 2 peaks identified

        %% Track a set of lane marking lines
        [Rep_ref, Count_ref] = videolanematching(Rep_ref, Count_ref, ...
                                    MaxLaneNum, ExpLaneNum, Enable, Line, ...
                                    TrackThreshold, frameFound+frameLost);

        % Convert lines from Polar to Cartesian space.
        Pts = step(hHoughLines1, Rep_ref(2,:), Rep_ref(1,:), Imlow);

        %% Detect whether there is a left or right lane departure.
        [~, NumNormalDriving, TwoLanes, OutMsg, leftIdx, rightIdx] = ...
                videodeparturewarning(Pts, Imlow, MaxLaneNum, Count_ref, ...
                                       NumNormalDriving, OutMsg);
        % Meaning of OutMsg: 0 = Right lane departure,
        %                    1 = Normal driving, 2 = Left lane departure

    %     % Detect the type and color of lane marker lines
    %     YCbCr  = rgb2ycbcr(double(RGB(NumRows+1:240, :, :)));
    %     ColorAndTypeIdx = videodetectcolorandtype(TwoLanes, YCbCr);
        % Meaning of ColorAndTypeIdx:
        % INVALID_COLOR_OR_TYPE = int8(0); 
        % YELLOW_BROKEN = int8(1); YELLOW_SOLID = int8(2);  
        % WHITE_BROKEN = int8(3);  WHITE_SOLID = int8(4).

        %% Output
        % left and right angle results
        leftTheta = Rep_ref(2,leftIdx)*180/pi;
        rightTheta = Rep_ref(2,rightIdx)*180/pi;

        % Correct positions of lines on original frame
        lineStruct = TwoLanes + [offset; offset]';
else
    lineStruct = [];
    leftTheta = [];
    rightTheta = [];
end
end
