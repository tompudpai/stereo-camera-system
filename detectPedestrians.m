function [pedStruct, Rep_ref_ped, Count_ref_ped] = detectPedestrians(frame, idx,...
            ptCloud, peopleDetector, tf_ped, bf_ped, Rep_ref_ped, Count_ref_ped, ...
            MaxPedNum, TrackThreshold_ped, frameFound_ped, frameLost_ped,...
            polyRatio, thresholdRatio, pedsOn)

if pedsOn
    
    if mod(idx,3) ~= 1

        %% Detect people using the people detector object
        % calculate region of interest
        [nr, nc, ~] = size(frame);
        ROI = [1 tf_ped*nr nc (bf_ped-tf_ped)*nr];

        bboxes = step(peopleDetector,frame, ROI);

        % If bounding box exceeds frame dimensions
        if bboxes(:,1) + bboxes(:,3) > nc
            bboxes(:,3) = nc - bboxes(:,1);
        end


        %% Match pedestrians

        [Rep_ref_ped, Count_ref_ped] = objectmatching(Rep_ref_ped, Count_ref_ped, ...
                                        MaxPedNum, bboxes, TrackThreshold_ped, frameFound_ped+frameLost_ped);
                                    
    end
    %% Identify pedestrians with sufficient count 
    peds = [];
    pedIdx = [];
    for i = 1:MaxPedNum
        if Count_ref_ped(i) >= frameFound_ped
            peds = [peds; Rep_ref_ped(:, i)'];
            pedIdx = [pedIdx; i];
        end
    end
    
    %% Identify the depth of the active pedestrians
    if any(peds)
        % extract a roi from z layer of point cloud
        x1 = peds(:,1);
        x2 = peds(:,1)+peds(:,3);
        y1 = peds(:,2);
        y2 = peds(:,2)+peds(:,4);
    end
    
    pedSize = size(peds,1);
    dist = ones(1, pedSize);

    for j = 1:pedSize
        ptCloudZRoi = ptCloud(y1(j):y2(j),x1(j):x2(j),3);
        % calculate the average z value or distance
        dist(j) = mean(ptCloudZRoi(:),'omitnan');
    end
    
    %% Detect location of vehicle
    [nr, nc, ~] = size(frame);
    if any(peds)
        pos = findPosition(peds, pedSize, polyRatio, thresholdRatio, nr, nc, tf_ped, bf_ped);
    else
        pos = [];
    end
    
    %% Place active pedestrians into output struct      
    pedStruct = struct('boxes', peds,'idx',pedIdx,'dist',dist,'pos',pos);
    
else
%     peds = [];
%     pedIdx = 0;
    pedStruct = struct('boxes', [],'idx',[],'dist',[],'pos',[]);
end