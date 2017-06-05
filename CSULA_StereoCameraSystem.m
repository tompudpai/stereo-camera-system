%% CSULA ADAS Stereo Camera System Program
% Simultaneously identifies, tracks, and find distances for lanes, pedestrians, signs, and vehicles
%%
clc
clear
close all

%% Load global parameters and system objects
loadParameters();

%% Initialize Video Objects

if cameraOn
    % Initialize webcams
    camL = webcam(2);
    camR = webcam(3);
    %[height_Log, width_Log, channels_Log] = size(snapshot(camL));
else
    % Create a VideoFileReader System object to read video from a file.
    % VR1 = vision.VideoFileReader('viplanedeparture.mp4');
    % VR1 = vision.VideoFileReader('Activity1_Signs_Left_CSULA.mp4');
%     VR1 = vision.VideoFileReader('Activity1PedsClip.avi');
    VR1 = vision.VideoFileReader('Activity1CarsClip.avi');
%     VR1 = vision.VideoFileReader('Activity1SignsClip.avi');
    % VR1 = vision.VideoFileReader('vipwarnsigns.avi');
    
%     VR1 = vision.VideoFileReader('rawCompVideoLeft2.avi');
%     VR1 = vision.VideoFileReader([userpath '\Examples\compClipTestLeft3.avi']);
%     VR2 = vision.VideoFileReader('rawCompVideoRight2.avi');
%     VR2 = vision.VideoFileReader([userpath '\Examples\compClipTestRight3.avi']);
    

    % VR2 = vision.VideoFileReader('viplanedeparture.mp4');
    % VR2 = vision.VideoFileReader('Activity1_Signs_Left_CSULA.mp4');
%     VR2 = vision.VideoFileReader('Activity1PedsClip2.avi');
    VR2 = vision.VideoFileReader('Activity1CarsClip2.avi');
%     VR2 = vision.VideoFileReader('Activity1SignsClip2.avi');
    % VR2 = vision.VideoFileReader('vipwarnsigns.avi');
end


% Create a VideoPlayer System object to visualize video
VP = vision.DeployableVideoPlayer;

% Create a VideoFileWriter System object to write video to a file.
VW = vision.VideoFileWriter([userpath '\CSULA_StereoCameraSystemTestRun9.mp4'],...
    'FileFormat', 'MPEG4', 'FrameRate', 5);


%% Initialize .csv file
categories = ['Time(s),'...
    'Veh1ID,Veh1Distance(m),Veh1LanePos(0|1|2|3),'...
    'Veh2ID,Veh2Distance(m),Veh2LanePos(0|1|2|3),'...
    'Veh3ID,Veh3Distance(m),Veh3LanePos(0|1|2|3),'...
    'Veh4ID,Veh4Distance(m),Veh4LanePos(0|1|2|3),'...
    'Veh5ID,Veh5Distance(m),Veh5LanePos(0|1|2|3),'...
    'Ped1ID,Ped1Distance(m),Ped1Pos(0|1|2|3),'...
    'Ped2ID,Ped2Distance(m),Ped2Pos(0|1|2|3),'...
    'Ped3ID,Ped3Distance(m),Ped3Pos(0|1|2|3),'...
    'Ped4ID,Ped4Distance(m),Ped4Pos(0|1|2|3),'...
    'Ped5ID,Ped5Distance(m),Ped5Pos(0|1|2|3),'...
    'Sign1ID,Sign1Distance(m),Sign1Type(0|1|2|3),'...
    'Sign2ID,Sign2Distance(m),Sign2Type(0|1|2|3),'...
    'Sign3ID,Sign3Distance(m),Sign3Type(0|1|2|3),'...
    'Sign4ID,Sign4Distance(m),Sign4Type(0|1|2|3),'...
    'Sign5ID,Sign5Distance(m),Sign5Type(0|1|2|3)'];
csvName = ['CSULA_ADAS_' datestr(now,'yyyymmdd_HHMM') '.csv'];

if writeResults
    dlmwrite(csvName, categories, 'delimiter', '');
end

%% Initialize Data
% Record frame index
idx = 0;

% Record times for each detector
dispTime = 0;
laneTime = 0;
pedTime = 0;
signTime = 0;
vehTime = 0;

% Previous time that the frame was recorded (for correct csv time entries)
prevToc = 0;

%% Loop through each frame and find traffic objects

% Begin loop on keyboard input
disp('Press any key when ready to begin processing:')
pause;

% Start overall timer
tic % overall timer

% while idx < 100
while(~isDone(VR1))
% for i = 1:10

% cont = 1;
% while cont

    % Start iteration timer   
    itTime = tic;
    
    idx = idx + 1;
    
    % Acquire next frame
%     frame = step(VR1);
%     frame2 = step(VR2);
%     frame = imread('obscured.jpg');
%     frame2 = imread('obscured.jpg');

    if cameraOn
        frame = snapshot(camL);
        frame2 = snapshot(camR);
    else
        % Acquire next frame
        frame = step(VR1);
        frame2 = step(VR2);
%         frame = imread('obscured.jpg');
%         frame2 = imread('obscured.jpg');
    end
   
    % Rectify the images.
    [frame, frame2] = rectifyStereoImages(frame, frame2, stereoParams);
    
    % Check for obstruction in front of cameras - edit later
    if mod(idx,2) == 0 || idx == 1 % detect system fault on every other frame
        sysFault = detectSystemFault(frame, frame2, obstructedThreshold, sysFaultOn);
    end
    
    % If no obstructions, proceed
    if( ~sysFault.left && ~sysFault.right)
        
        % All structs in a parfor loop must have outputs of the same variable
        % type to be accessed outside the loop. Therefore, an empty struct of 4
        % fields is created here.
        %parfor i = 1:4 % test to see if this is faster on your computer
        
        % Calculate disparity map
        dispTimer = tic;
        if mod(idx, 2) ~= 2
            ptCloud = findDisparity(frame, frame2, stereoParams, disparityRange, thresholds, dispOn);
        end
        dispTime = dispTime + toc(dispTimer);

        if switchCamera
            % switch frame and frame2
            temp = frame;
            frame2 = frame;
            frame = temp;
        end

        % increase brightness
        if brightnessOn
            frameArray1 = frame(:);
            frame = frame * (1 + (255-max(frameArray1))/255);
            frameArray2 = frame2(:);
            frame2 = frame2 * (1 + (255-max(frameArray2))/255);
        end

% frame2 = frame2/max(frameArray2);
        
        % Lane detection algorithm
        laneTimer = tic;
%         lanes = detectLanes(frame, lanesOn);
        [lanes, Rep_ref, Count_ref, NumNormalDriving, OutMsg, leftTheta, rightTheta] ...
            = detectLanes3(frame, Rep_ref, Count_ref, NumRows, TrackThreshold, ...
            NumNormalDriving,OutMsg,ExpLaneNum,MaxLaneNum,frameFound,frameLost,lanesOn);
        laneTime = laneTime + toc(laneTimer);
        
        % Pedestrian detection algorithm
        pedTimer = tic;
        [peds, Rep_ref_ped, Count_ref_ped] = detectPedestrians(frame, idx, ptCloud, peopleDetector,...
            tf_ped, bf_ped, Rep_ref_ped, Count_ref_ped, MaxPedNum, TrackThreshold_ped, frameFound_ped,...
            frameLost_ped, polyRatio_ped, thresholdRatio_ped, pedsOn);     
        pedTime = pedTime + toc(pedTimer);
        
        % Sign detection algorithm
        signTimer = tic;
%         signs = detectSigns(frame, stopSignDetector, signsOn);
%         [signs, Rep_ref_stopSign, Count_ref_stopSign, Rep_ref_yieldSign, ...
%             Count_ref_yieldSign, Rep_ref_SLSign, Count_ref_SLSign] = ...
%             detectSigns(frame,idx, ptCloud, ...
%             stopSignDetector, yieldSignDetector, speedLimitSignDetector, tf_sign, bf_sign, ...
%             Rep_ref_stopSign, Count_ref_stopSign, Rep_ref_yieldSign, Count_ref_yieldSign,...
%             Rep_ref_SLSign, Count_ref_SLSign, MaxSignNum, TrackThreshold_sign, ...
%             frameFound_sign, frameLost_sign, signsOn);
        [signs, Rep_ref_sign, Count_ref_sign, Label_ref_sign] = ...
            detectSigns(frame,idx, ptCloud, ...
            stopSignDetector, yieldSignDetector, speedLimitSignDetector, tf_sign, bf_sign,...
            lf_sign, rf_sign, Rep_ref_sign, Count_ref_sign, Label_ref_sign, MaxSignNum,...
            TrackThreshold_sign, frameFound_sign, frameLost_sign, signsOn);
        signTime = signTime + toc(signTimer);
        
        % Vehicle detection + distance calculation
        % Will require frames from 2 cameras - edit later
        vehTimer = tic;
%         vehicles = detectVehicles(frame, ptCloud, COD, tf_veh, bf_veh, vehOn);
        [vehicles, Rep_ref_veh, Count_ref_veh] = detectVehicles(frame, idx, ptCloud,...
            vehicleDetector, vehicleDetector2, tf_veh, bf_veh, Rep_ref_veh, Count_ref_veh, ...
            MaxVehNum, TrackThreshold_veh, frameFound_veh, frameLost_veh, ...
            polyRatio_veh, thresholdRatio_veh,vehOn);
        vehTime = vehTime + toc(vehTimer);
    
        % Overlay annotated bounding boxes on frame
        frameOut = overlay(frame,idx,lanes,peds,signs,vehicles,showText);
    %     frameOut = frame;
    else
        % Show system fault detected message
        if sysFault.left && sysFault.right
            frameOut = insertText(frame, [1 size(frame,1)-45], 'Both cameras obstructed');
        elseif sysFault.left
            frameOut = insertText(frame, [1 size(frame,1)-45], 'Left camera obstructed');
        else
            frameOut = insertText(frame, [1 size(frame,1)-45], 'Right camera obstructed');
        end
    end
    
    %insert FPS of the current frame
%     fpsPos = [1 size(frame,1)-22];
%     fpsStr = [num2str(1/toc(itTime), '%.2f') ' fps'];
%     frameOut = insertText(frame, fpsPos, fpsStr);
    if showFPS
        frameOut = insertText(frameOut, [1 size(frameOut,1)-22], [num2str(1/toc(itTime), '%.2f') ' fps'], 'Font', 'Arial');
    end
        
    
	% Update video player
    if(playVideoOn)
        step(VP,frameOut);
    end
    
    if writeVideoOn
        step(VW, frameOut);
    end
    
    % Update results.csv file
    if writeResults && ~(sysFault.left || sysFault.right)
        updateCSV;
    end
    cont = isOpen(VP);
end

totalTime = toc;
disp([num2str(idx/totalTime, '%.2f') ' fps average'])
disp(['Time spent on disparity calculation: ' num2str(dispTime, '%.2f') ' s or ' ...
    num2str(dispTime/totalTime*100, '%.2f') '% of total time'])
disp(['Time spent on lane detection: ' num2str(laneTime, '%.2f') ' s or ' ...
    num2str(laneTime/totalTime*100, '%.2f') '% of total time'])
disp(['Time spent on pedestrian detection: ' num2str(pedTime, '%.2f') ' s or ' ...
    num2str(pedTime/totalTime*100, '%.2f') '% of total time'])
disp(['Time spent on sign detection: ' num2str(signTime, '%.2f') ' s or ' ...
    num2str(signTime/totalTime*100, '%.2f') '% of total time'])
disp(['Time spent on vehicle detection: ' num2str(vehTime, '%.2f') ' s or ' ...
    num2str(vehTime/totalTime*100, '%.2f') '% of total time'])

release(VP);
release(VW);
% release(VR1);
% release(VR2);
