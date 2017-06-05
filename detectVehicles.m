function [vehicleStruct, Rep_ref_veh, Count_ref_veh] = detectVehicles(frame, idx,...
            ptCloud, vehicleDetector, vehicleDetector2, tf_veh, bf_veh, Rep_ref_veh, Count_ref_veh, ...
            MaxVehNum, TrackThreshold_veh, frameFound_veh, frameLost_veh,...
            polyRatio, thresholdRatio, vehOn)

if vehOn 
    
    if mod(idx,3) ~= 2

        %% CSULA distance detector with stereo cameras
        % This part of the script detects the distance
        % Requires thresholdPC.m

        %% Detect vehicles  

        % Extract the middle of the frame
    %     [nr,nc,~] = size(frame1);

        % calculate region of interest
        [nr, nc, ~] = size(frame);
        ROI = [1 nr*tf_veh nc nr*(bf_veh-tf_veh)];

        % Find the bounding boxes from COD
    %     CODbboxes = step(COD, frame1, ROI);
        bboxes = step(vehicleDetector, frame, ROI);
        bboxes2 = step(vehicleDetector2, frame, ROI);
%         bboxes = [bboxes; bboxes2];
%         invertedFrame = 255-frame;
%         bboxes3 = step(vehicleDetector, invertedFrame, ROI);
%         bboxes4 = step(vehicleDetector2, invertedFrame, ROI);
%         bboxes = [bboxes; bboxes2; bboxes3; bboxes4];

    %     % Find number of bounding boxes from ground truth and detections
    %     sizeCODbboxes = size(bboxes);
    %     %count = size(CODbboxes(:,1));
    
    %% For any overlapping detections, choose the smaller box
     numBboxes = size(bboxes, 1);
     numBboxes2 = size(bboxes2, 1);
     
     count1 = zeros(1,numBboxes);
     count2 = zeros(1,numBboxes2);
    
    for i = 1:numBboxes
         for j = 1:numBboxes2
             if ~isempty(bboxes) && ~isempty(bboxes2)
                 if bboxOverlapRatio(bboxes(i,:), bboxes2(j,:)) > 0
                     % find area of both boxes
                    area1 = bboxes(i,3) * bboxes(i,4);
                    area2 = bboxes2(j,3) * bboxes2(j,4);
                    if (area1 > area2)
                        count2(j) = count2(j) + 1;
                    else
                        count1(i) = count1(i) + 1;
                    end
                 end
             end
         end
    end
     
    deleteRow = [];
     for i = 1:numBboxes
         if(count1(i) > 0)
             deleteRow = [deleteRow i];
         end
     end
     bboxes(deleteRow,:) = [];
     
     deleteRow = [];
     for i = 1:numBboxes2
         if(count2(i) > 0)
             deleteRow = [deleteRow i];
         end
     end
     bboxes2(deleteRow,:) = [];
    
     bboxes = [bboxes; bboxes2];

        %% Match vehicles

        [Rep_ref_veh, Count_ref_veh] = objectmatching(Rep_ref_veh, Count_ref_veh, ...
                                        MaxVehNum, bboxes, TrackThreshold_veh, frameFound_veh+frameLost_veh);
    end
                                
    %% Identify vehicles with sufficient count 
    vehicles = [];
    vehIdx = [];
    for i = 1:MaxVehNum
        if Count_ref_veh(i) >= frameFound_veh
            vehicles = [vehicles; Rep_ref_veh(:, i)'];
            vehIdx = [vehIdx; i];
        end
    end

    %% Identify the depth of the vehicle in front    
    if any(vehicles)
        % extract a roi from z layer of point cloud
        x1 = vehicles(:,1);
        x2 = vehicles(:,1)+vehicles(:,3);
        y1 = vehicles(:,2);
        y2 = vehicles(:,2)+vehicles(:,4);
        
%         x1 = vehicles(:,1) + floor(vehicles(:,3)/4);
%         x2 = vehicles(:,1)+floor(3*vehicles(:,3)/4);
%         y1 = vehicles(:,2) + floor(vehicles(:,4)/4);
%         y2 = vehicles(:,2)+floor(3*vehicles(:,4)/4);

        % roughly scale roi to rectified dimensions
%         sizeJL = size(JL);
%         sizeILO = size(frame1);
%         x1 = int16(x1 * sizeJL(2)/sizeILO(2));
%         x2 = int16(x2 * sizeJL(2)/sizeILO(2));
%         y1 = int16(y1 * sizeJL(1)/sizeILO(1));
%         y2 = int16(y2 * sizeJL(1)/sizeILO(1));
    end

    vehSize = size(vehicles,1);
    dist = zeros(1, vehSize);

    for j = 1:vehSize
        ptCloudZRoi = ptCloud(y1(j):y2(j),x1(j):x2(j),3);
        
        % calculate the average z value or distance
        dist(j) = mean(ptCloudZRoi(:),'omitnan');
    end

    %% Detect location of vehicle
    [nr, nc, ~] = size(frame);
    if any(vehicles)
        pos = findPosition(vehicles, vehSize, polyRatio, thresholdRatio, nr, nc, tf_veh, bf_veh);
    else
        pos = [];
    end

    %% Place vehicles into output struct
    vehicleStruct = struct('boxes', vehicles, 'idx', vehIdx, 'dist', dist, 'pos',pos);
    
else
    vehicleStruct = struct('boxes',[],'idx',[],'dist',[],'pos',[]);
end