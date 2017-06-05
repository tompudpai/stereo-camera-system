function ptCloud = findDisparity(JL, JR, stereoParams, disparityRange, thresholds, dispOn)

if dispOn
    %% Generate Disparity Map
    % Setting frames to type uint8 speeds up the disparity calculation
%     disparityMap = disparity(uint8(rgb2gray(JL)),uint8(rgb2gray(JR)),'DisparityRange',disparityRange);
    disparityMap = disparity(rgb2gray(JL),rgb2gray(JR),'DisparityRange',disparityRange);

    %% Reconstruct Point Cloud
    % create an empty stereo parameters object
    ptCloud = reconstructScene(disparityMap, stereoParams);
    % Convert from millimeters to meters.
    ptCloud = ptCloud/1000;

    %% Limit the range of Z and X for display.
    ptCloud = thresholdPC(ptCloud, thresholds);
else
    ptCloud = zeros(size(JL, 1), size(JL, 2), 3);
end