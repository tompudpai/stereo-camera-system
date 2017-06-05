%% Global Parameters

% Control input settings
cameraOn = 0;
brightnessOn = 0;
switchCamera = 0;

% Control which detectors are active
sysFaultOn = 1;
dispOn = 1;
lanesOn = 0;
pedsOn = 0;
signsOn = 0;
vehOn = 1;

% Control output settings
showText = 1;
showFPS = 0;
playVideoOn = 1; % for displaying video player
writeVideoOn = 1; % for writing output video
writeResults = 1; % for writing results to .csv file

%% System Fault detection parameters
% Threshold for variances of frame values determined experimentally
if cameraOn
    obstructedThreshold = 1500; %10;%100; %1.3e-5;
else
    obstructedThreshold = 10;
end

%% Disparity map specific parameters
% Create the disparity map with already-rectified images
disparityRange = [0 64];
% Limit the range of Z and X for display (in meters).
thresholds=[-5 5;-5 10;0 30];%[-5 5; -5 10; 0 100];  


%% Lane detection specific parameters
NumRows = 240; % Number of rows in the image region to process.
MaxLaneNum = 20; % Maximum number of lanes to store in the tracking repository.
ExpLaneNum = 2;  % Maximum number of lanes to find in the current frame.
Rep_ref   = zeros(2, MaxLaneNum); % Stored lines
Count_ref = zeros(1, MaxLaneNum); % Count of each stored line
TrackThreshold = 75; % Maximum allowable change of lane distance
                     % metric between two frames.
% Minimum number of frames a lane must be detected to become a valid lane.
frameFound = 5;
% Maximum number of frames a lane can be missed without marking it invalid. 
frameLost = 20;

NumNormalDriving = 0;
OutMsg = int8(-1);
offset = int32([0, NumRows, 0, NumRows]);

%% Pedestrian detection specific parameters
% Set up People Detector
peopleDetector = vision.PeopleDetector(...
    'UprightPeople_96x48',... 
    'WindowStride',[8 8],...  % increasing improves performance, decreases accuracy
    'ClassificationThreshold',1,... % increase to reduce false detections
    'MaxSize', [144 81],... % knowing the max size improves performance
    'UseROI', 1); % knowing region of interest improves performance
% MODIFY all of the above parameters for accuracy

% top of region of interest
tf_ped = 0.35;
% bottom of region of interest
bf_ped = 1.0;

MaxPedNum = 10; % Maximum number of pedestrians to store in the tracking repository.
Rep_ref_ped   = zeros(4, MaxPedNum); % Stored pedestrians
Count_ref_ped = zeros(1, MaxPedNum); % Count of each stored pedestrian
TrackThreshold_ped = 75; % Maximum allowable change of pedestrian
                     % distance metric between two frames.
% Minimum number of frames a pedestrian must be detected to become valid.
frameFound_ped = 2;
% Maximum number of frames a pedestrian can be missed without marking it invalid. 
frameLost_ped = 6;

% Define widths of polygon region to search for cars in current lane
polyRatio_ped = [.41 .59 .75 .25];  %[topLeft topRight bottomLeft bottomRight
thresholdRatio_ped = 0.5; % Percent overlap to be considered within current lane

%% Sign detection specific parameters
% Use trained classifier to detect a stop sign in an image.
stopSignDetector = vision.CascadeObjectDetector('stopSignDetector.xml', 'UseROI', 1);
yieldSignDetector = vision.CascadeObjectDetector('yieldSignDetector2.xml', 'UseROI', 1);
speedLimitSignDetector = vision.CascadeObjectDetector('speedlimitSignDetector2.xml', 'UseROI', 1);
% top of region of interest
tf_sign = 0.4;
% bottom of region of interest
bf_sign = 0.8;

lf_sign = 0.42;
rf_sign = 1.0;

MaxSignNum = 20; % Maximum number of signs to store in the tracking repository.
Rep_ref_sign = zeros(4, MaxSignNum); % Stored signs
Count_ref_sign = zeros(4, MaxSignNum); % Count of each stored sign 
Label_ref_sign = zeros(MaxSignNum, 1); % Label of each stored sign

% Rep_ref_stopSign   = zeros(4, MaxSignNum); % Stored stop signs
% Count_ref_stopSign = zeros(1, MaxSignNum); % Count of each stored stop sign
% Rep_ref_yieldSign   = zeros(4, MaxSignNum); % Stored stop signs
% Count_ref_yieldSign = zeros(1, MaxSignNum); % Count of each stored stop sign
% Rep_ref_SLSign   = zeros(4, MaxSignNum); % Stored stop signs
% Count_ref_SLSign = zeros(1, MaxSignNum); % Count of each stored stop sign
TrackThreshold_sign = 75; % Maximum allowable change of sign
                     % distance metric between two frames.
% Minimum number of frames a sign must be detected to become valid.
frameFound_sign = 2;
% Maximum number of frames a sign can be missed without marking it invalid. 
frameLost_sign = 8;

%% Vehicle detection specific parameters
% Load stereo camera parameters (takes significant time)
load('stereoParamsLogitech.mat');
% load('stereoParams2.mat');
% Set up Cascade Object Detector
vehicleDetector = vision.CascadeObjectDetector('CarDetector.xml', 'UseROI', 1);
% vehicleDetector2 = vision.CascadeObjectDetector('blackCarDetector.xml', 'UseROI', 1);
vehicleDetector2 = vision.CascadeObjectDetector('CarDetector.xml','UseROI',1);
% crop video mid-section
tf_veh = 0.45;
bf_veh = 0.95;

MaxVehNum = 10; % Maximum number of vehicles to store in the tracking repository.
Rep_ref_veh   = zeros(4, MaxVehNum); % Stored vehicles
Count_ref_veh = zeros(1, MaxVehNum); % Count of each stored vehicle
TrackThreshold_veh = 100; % Maximum allowable change of vehicle
                     % distance metric between two frames.
% Minimum number of frames a vehicle must be detected to become valid.
frameFound_veh = 2;
% Maximum number of frames a vehicle can be missed without marking it invalid. 
frameLost_veh = 6;

% Define widths of polygon region to search for cars in current lane
polyRatio_veh = [.41 .59 .75 .25];  %[topLeft topRight bottomLeft bottomRight
thresholdRatio_veh = 0.5; % Percent overlap to be considered within current lane