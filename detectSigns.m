% function [signStruct, ...
% %     Rep_ref_stopSign, Count_ref_stopSign, Rep_ref_yieldSign, ...
% %             Count_ref_yieldSign, Rep_ref_SLSign, Count_ref_SLSign...
%             Rep_ref_sign, Count_ref_sign] = ...
%             detectSigns(frame, idx, ptCloud, stopSignDetector, yieldSignDetector, ...
%             speedLimitSignDetector, tf_sign, bf_sign, ...
%             Rep_ref_sign, Count_ref_sign, ...
% %             Rep_ref_stopSign, ...
% %             Count_ref_stopSign, Rep_ref_yieldSign, Count_ref_yieldSign,...
% %             Rep_ref_SLSign, Count_ref_SLSign,...
%             MaxSignNum, TrackThreshold_sign, ...
%             frameFound_sign, frameLost_sign, signsOn)
function [signStruct, Rep_ref_sign, Count_ref_sign, Label_ref_sign] = ...
            detectSigns(frame, idx, ptCloud, stopSignDetector, yieldSignDetector, ...
            speedLimitSignDetector, tf_sign, bf_sign, lf_sign, rf_sign, ...
            Rep_ref_sign, Count_ref_sign, Label_ref_sign, ...
            MaxSignNum, TrackThreshold_sign, ...
            frameFound_sign, frameLost_sign, signsOn)

if signsOn
    
    if mod(idx,3) == 0 %mod(idx,2) == 1%1%mod(idx,3) == 2

        %% Detect sign using the cascade object detector object

        % calculate region of interest
        [nr, nc, ~] = size(frame);
%         ROI = [lf_sign*nc tf_sign*nr (rf_sign-lf_sign)*nc (bf_sign-tf_sign)*nr];
         ROI = [1 tf_sign*nr 1*nc (bf_sign-tf_sign)*nr];

        % Detect signs
        stopSignBbox = step(stopSignDetector, frame, ROI); 
        yieldSignBbox = step(yieldSignDetector, frame, ROI);
        SLSignBbox = step(speedLimitSignDetector, frame, ROI);
        
    %     stopSignBbox = step(stopSignDetector, frame); 
    %     boxes = {bbox};
    %     [labels{1, 1:size(bbox,1)}] = deal('sign');

    %     % REPLACE this section with detector implementation results
    %     boxes = zeros(0,4); % REPLACE with actual boxes
    %     [labels{1, 1:0}] = deal(''); % REPLACE with actual sign labels
    
     %% For any overlapping detections, choose the best detection
     numStopBox = size(stopSignBbox, 1);
     numYieldBox = size(yieldSignBbox, 1);
     numSLBox = size(SLSignBbox, 1);
     
     countStop = zeros(1,numStopBox);
     countYield = zeros(1,numYieldBox);
     countSL = zeros(1,numSLBox);
     
     % if 3 overlapping detecctions
     for i = 1:numStopBox
         for j = 1:numYieldBox
             for k = 1:numSLBox
                 if ~isempty(stopSignBbox) && ~isempty(yieldSignBbox) && ~isempty(SLSignBbox)
                     if bboxOverlapRatio(stopSignBbox(i,:), yieldSignBbox(j,:)) > 0 && ....
                             bboxOverlapRatio(stopSignBbox(i,:), SLSignBbox(k,:)) > 0 && ...
                             bboxOverlapRatio(yieldSignBbox(j,:), SLSignBbox(k,:)) > 0
                        a = frame(stopSignBbox(i,2):stopSignBbox(i,2)+stopSignBbox(i,4), stopSignBbox(i,1):stopSignBbox(i,1)+stopSignBbox(i,3),:);
                        b = frame(yieldSignBbox(j,2):yieldSignBbox(j,2)+yieldSignBbox(j,4), yieldSignBbox(j,1):yieldSignBbox(j,1)+yieldSignBbox(j,3),:);
                        c = frame(SLSignBbox(k,2):SLSignBbox(k,2)+SLSignBbox(k,4), SLSignBbox(k,1):SLSignBbox(k,1)+SLSignBbox(k,3),:);

                        a =  mean(mean(a(:,:,1))/mean(mean(mean(a(:,:,2:3)))));
                        b =  mean(mean(b(:,:,1))/mean(mean(mean(b(:,:,2:3)))));
                        c = mean(mean(c(:,:,1))/mean(mean(mean(c(:,:,2:3)))));

                        if (a > b && a > c) % High ratio of red implies stop sign
%                             yieldSignBbox(j, :) = [];
%                             SLSignBbox(k, :) = [];
                            countYield(j) = countYield(j) + 1;
                            countSL(k) = countSL(k) + 1;
                        elseif (b > c && b > a) % less high ratio of red implies yield
%                             stopSignBbox(i, :) = [];
%                             SLSignBbox(k, :) = [];
                            countStop(i) = countStop(i) + 1;
                            countSL(k) = countStop(k) + 1;
                        else % low ratio of red implies speed limit
%                             stopSignBbox(i, :) = [];
%                             yieldSignBbox(j, :) = [];
                            countStop(i) = countStop(i) + 1;
                            countYield(j) = countYield(j) + 1;
                        end

                     end
                 end
             end
         end
     end
     
     % if 2 overlapping detections
     for i = 1:numStopBox
         for j = 1:numYieldBox
             if ~isempty(stopSignBbox) && j <= ~isempty(yieldSignBbox)
                 if bboxOverlapRatio(stopSignBbox(i,:), yieldSignBbox(j,:)) > 0
                    a = frame(stopSignBbox(i,2):stopSignBbox(i,2)+stopSignBbox(i,4), stopSignBbox(i,1):stopSignBbox(i,1)+stopSignBbox(i,3),:);
                    b = frame(yieldSignBbox(j,2):yieldSignBbox(j,2)+yieldSignBbox(j,4), yieldSignBbox(j,1):yieldSignBbox(j,1)+yieldSignBbox(j,3),:);
                    a =  mean(mean(a(:,:,1))/mean(mean(mean(a(:,:,2:3)))));
                    b =  mean(mean(b(:,:,1))/mean(mean(mean(b(:,:,2:3)))));
                    if (a > b)
                        countYield(j) = countYield(j) + 1;
%                       yieldSignBbox(j, :) = [];
    %                   yieldSignBbox = [yieldSignBbox(1:j-1,:); yieldSignBbox(j+1, end)];
                    else
                        countStop(i) = countStop(i) + 1;
%                       stopSignBbox(i, :) = [];
    %                   stopSignBbox = [stopSignBbox(1:i-1,:); stopSignBbox(i+1, end,:)];
                    end

                 end
             end
         end
     end
     
     for i = 1:numSLBox
         for j = 1:numYieldBox
             if ~isempty(yieldSignBbox) && ~isempty(SLSignBbox)
                 if bboxOverlapRatio(SLSignBbox(i,:), yieldSignBbox(j,:)) > 0
                    a = frame(SLSignBbox(i,2):SLSignBbox(i,2)+SLSignBbox(i,4), SLSignBbox(i,1):SLSignBbox(i,1)+SLSignBbox(i,3),:);
                    b = frame(yieldSignBbox(j,2):yieldSignBbox(j,2)+yieldSignBbox(j,4), yieldSignBbox(j,1):yieldSignBbox(j,1)+yieldSignBbox(j,3),:);
                    a =  mean(mean(a(:,:,1))/mean(mean(mean(a(:,:,2:3)))));
                    b =  mean(mean(b(:,:,1))/mean(mean(mean(b(:,:,2:3)))));
                    if (a > b)
%                         yieldSignBbox(j, :) = [];
                        countYield(j) = countYield(j) + 1;
                    else
                        countSL(i) = countSL(i) + 1;
%                         SLSignBbox(i, :) = [];
                    end
                 end
             end
         end
     end
%      
     for i = 1:numStopBox
         for j = 1:numSLBox
             if ~isempty(stopSignBbox) && ~isempty(SLSignBbox)
                 if bboxOverlapRatio(stopSignBbox(i,:), SLSignBbox(j,:)) > 0
                    a = frame(stopSignBbox(i,2):stopSignBbox(i,2)+stopSignBbox(i,4), stopSignBbox(i,1):stopSignBbox(i,1)+stopSignBbox(i,3),:);
                    b = frame(SLSignBbox(j,2):SLSignBbox(j,2)+SLSignBbox(j,4), SLSignBbox(j,1):SLSignBbox(j,1)+SLSignBbox(j,3),:);
                    a =  mean(mean(a(:,:,1))/mean(mean(mean(a(:,:,2:3)))));
                    b =  mean(mean(b(:,:,1))/mean(mean(mean(b(:,:,2:3)))));
                    if (a > b)
                        countSL(j) = countSL(j) + 1;
%                         SLSignBbox(j, :) = [];
                    else
                        countStop(i) = countStop(i) + 1;
%                         stopSignBbox(i, :) = [];
                    end
                 end
             end
         end
     end
    
     deleteRow = [];
     for i = 1:numStopBox
         if(countStop(i) > 0)
             deleteRow = [deleteRow i];
         end
     end
     stopSignBbox(deleteRow,:) = [];
     
     deleteRow = [];
     for i = 1:numYieldBox
         if(countYield(i) > 0)
             deleteRow = [deleteRow i];
         end
     end
     yieldSignBbox(deleteRow,:) = [];
     
     deleteRow = [];
     for i = 1:numSLBox
         if(countSL(i) > 0)
             deleteRow = [deleteRow i];
         end
     end
     SLSignBbox(deleteRow,:) = [];
     

%      i = uint8(0);
%      while(i < numStopBox)
%         if countStop(i) > 0
%             stopSignBbox(i, :) = [];
%             numStopBox = numStopBox - 1;
%         else
%             i = i + 1;
%         end
%      end
%      i = 0;
%      while(i < numYieldBox)
%         if countYield(i) > 0
%             yieldSignBbox(i, :) = [];
%             numYieldBox = numYieldBox - 1;
%         else
%             i = i + 1;
%         end
%      end
%      i = 0;
%      while(i < numSLBox)
%         if countSL(i) > 0
%             SLSignBbox(i, :) = [];
%             numSLBox = numSLBox - 1;
%         else
%             i = i + 1;
%         end
%      end

        %% Match signs
        
        [Rep_ref_sign, Count_ref_sign, Label_ref_sign] = signmatching(Rep_ref_sign, Count_ref_sign,...
            Label_ref_sign, MaxSignNum, stopSignBbox, yieldSignBbox, SLSignBbox, ...
            TrackThreshold_sign, frameFound_sign + frameLost_sign);

%         [Rep_ref_stopSign, Count_ref_stopSign] = objectmatching(Rep_ref_stopSign, ...
%             Count_ref_stopSign, MaxSignNum, stopSignBbox, TrackThreshold_sign, ...
%             frameFound_sign+frameLost_sign);
%         [Rep_ref_yieldSign, Count_ref_yieldSign] = objectmatching(Rep_ref_yieldSign, ...
%             Count_ref_yieldSign, MaxSignNum, yieldSignBbox, TrackThreshold_sign, ...
%             frameFound_sign+frameLost_sign);
%         [Rep_ref_SLSign, Count_ref_SLSign] = objectmatching(Rep_ref_SLSign, ...
%             Count_ref_SLSign, MaxSignNum, SLSignBbox, TrackThreshold_sign, ...
%             frameFound_sign+frameLost_sign);
    end
    
    %% Identify signs with sufficient count
 
    signs = [];
    signIdx = [];
    signLabel = [];
    for i = 1:MaxSignNum
        if Count_ref_sign(i) >= frameFound_sign
            signs =[signs; Rep_ref_sign(:, i)'];
            signIdx = [signIdx; i];
            signLabel = [signLabel; Label_ref_sign(i)];
        end
    end
%     stopSigns = [];
%     stopSignIdx = [];
%     for i = 1:MaxSignNum
%         if Count_ref_stopSign(i) >= frameFound_sign
%             stopSigns = [stopSigns; Rep_ref_stopSign(:, i)'];
%             stopSignIdx = [stopSignIdx; i];
%         end
%     end
%     
%     yieldSigns = [];
%     yieldSignIdx = [];
%     for i = 1:MaxSignNum
%         if Count_ref_yieldSign(i) >= frameFound_sign
%             yieldSigns = [yieldSigns; Rep_ref_yieldSign(:, i)'];
%             yieldSignIdx = [yieldSignIdx; i];
%         end
%     end
%     
%     SLSigns = [];
%     SLSignIdx = [];
%     for i = 1:MaxSignNum
%         if Count_ref_SLSign(i) >= frameFound_sign
%             SLSigns = [SLSigns; Rep_ref_SLSign(:, i)'];
%             SLSignIdx = [SLSignIdx; i];
%         end
%     end
    
    %% Identify the depth of the active signs
    if any(signs)
        % extract a roi from z layer of point cloud
        x1 = signs(:,1);
        x2 = signs(:,1)+signs(:,3);
        y1 = signs(:,2);
        y2 = signs(:,2)+signs(:,4);
    end
    numSign = size(signs,1);
    signDist = ones(1, numSign);

    for j = 1:numSign
        ptCloudZRoi = ptCloud(y1(j):y2(j),x1(j):x2(j),3);
        % calculate the average z value or distance
        signDist(j) = mean(ptCloudZRoi(:),'omitnan');
    end
%     if any(stopSigns)
%         % extract a roi from z layer of point cloud
%         x1 = stopSigns(:,1);
%         x2 = stopSigns(:,1)+stopSigns(:,3);
%         y1 = stopSigns(:,2);
%         y2 = stopSigns(:,2)+stopSigns(:,4);
%     end
%     
%     numStopSign = size(stopSigns,1);
%     stopSignDist = ones(1, numStopSign);
% 
%     for j = 1:numStopSign
%         ptCloudZRoi = ptCloud(y1(j):y2(j),x1(j):x2(j),3);
%         % calculate the average z value or distance
%         stopSignDist(j) = mean(ptCloudZRoi(:),'omitnan');
%     end
%     
%     if any(yieldSigns)
%         % extract a roi from z layer of point cloud
%         x1 = yieldSigns(:,1);
%         x2 = yieldSigns(:,1)+yieldSigns(:,3);
%         y1 = yieldSigns(:,2);
%         y2 = yieldSigns(:,2)+yieldSigns(:,4);
%     end
%     
%     numYieldSign = size(yieldSigns,1);
%     yieldSignDist = ones(1, numYieldSign);
% 
%     for j = 1:numYieldSign
%         ptCloudZRoi = ptCloud(y1(j):y2(j),x1(j):x2(j),3);
%         % calculate the average z value or distance
%         yieldSignDist(j) = mean(ptCloudZRoi(:),'omitnan');
%     end
%     
%     if any(SLSigns)
%         % extract a roi from z layer of point cloud
%         x1 = SLSigns(:,1);
%         x2 = SLSigns(:,1)+SLSigns(:,3);
%         y1 = SLSigns(:,2);
%         y2 = SLSigns(:,2)+SLSigns(:,4);
%     end
%     
%     numSLSign = size(SLSigns,1);
%     SLSignDist = ones(1, numSLSign);
% 
%     for j = 1:numSLSign
%         ptCloudZRoi = ptCloud(y1(j):y2(j),x1(j):x2(j),3);
%         % calculate the average z value or distance
%         SLSignDist(j) = mean(ptCloudZRoi(:),'omitnan');
%     end
    
    %% Place active pedestrians into output struct   
    signStruct = struct('boxes', signs, 'idx', signIdx, 'dist', signDist, 'label', signLabel);
%     signStruct = struct('stopBoxes', stopSigns,'stopIdx',stopSignIdx,'stopDist',stopSignDist,...
%         'yieldBoxes', yieldSigns,'yieldIdx',yieldSignIdx,'yieldDist',yieldSignDist,...
%         'SLBoxes', SLSigns,'SLIdx',SLSignIdx,'SLDist',SLSignDist);
else
%     signs = [];
%     signIdx = 0;
    signStruct = struct('boxes', [], 'idx', [], 'dist', [], 'label', []);
%     signStruct = struct('stopBoxes', [],'stopIdx',[],'stopDist',[],...
%         'yieldBoxes', [],'yieldIdx',[],'yieldDist',[],...
%         'SLBoxes', [],'SLIdx',[],'SLDist',[]);
end