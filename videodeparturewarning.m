function [TwoValidLanes, NumNormalDriving, TwoLanes, OutMsg, leftIdx, rightIdx] = ...
            videodeparturewarning(Pts, Imlow, MaxLaneNum, Count_ref, ...
                NumNormalDriving, OutMsg)
% VIDEODEPARTUREWARNING - Detect whether there is a lane departure

% Pts = step(hHoughLines1, Rep_ref(2,:), Rep_ref(1,:), Imlow); %Converted lines from Polar to Cartesian space.
% Imlow  = RGB(NumRows+1:end, :, :); % lower portion of input video 
% MaxLaneNum = 20; % Maximum number of lanes to store in the tracking repository.
% Count_ref = zeros(1, MaxLaneNum); % Count of each stored line
% % Initially: 
% NumNormalDriving = 0;
% OutMsg = int8(-1);

% Indices of left and right lines
leftIdx = 1;
rightIdx = 1;

% Find the line which intersects with the image bottom boundary to the
% left (right) and which is the closest to the image bottom boundary
% center.
Dis_inf = size(Imlow, 2); % Width of image = 360 in original video
Halfwidth = Dis_inf * 0.5; % find half of image width = 180 in original video
Left_dis  = single(intmax('int16')); % = 32767
Left_pts  = zeros(4, 1); % 4 x 1 matrix of 0's
Right_dis = single(intmax('int16')); % = 32767
Right_pts = zeros(4, 1); % 4 x 1 matrix of 0's
Pts = Pts(:, [2 1 4 3])'; %rearrange into 4 x 20 matrix [y1 x1 y2 x2]' format

for i = 1:MaxLaneNum % for each of 20 lines from repository
    % Pick the column corresponding to the point closer to the top
    if Pts(1, i) >= Pts(3, i) % if y1 > y2
        ColNum = Pts(2, i); % colnum = x1
    else
        ColNum = Pts(4, i); % else colnum = x2
    end
    if Count_ref(i) >= 5 % if count >= 5 because of framesfound? EDIT to control line detection sensitivity
        centerDis = abs(Halfwidth - ColNum); % horizontal distance from center to top of line 
    else
        centerDis = Dis_inf; % otherwise image width
    end
    if (Halfwidth - ColNum) >= 0 % left lane
        if centerDis < Left_dis % if this is next smallest left distance
            Left_dis = centerDis; % set left_dis to horizontal distance
            Left_pts = Pts(:, i); % reset left points
            leftIdx = i;
        end
    else                         % right lane
        if centerDis < Right_dis % if this is next smallest right distance
            Right_dis = centerDis; % set right_dis to horizontal distance
            Right_pts = Pts(:, i); % reset right points
            rightIdx = i;
        end
    end
end

% Departure detection
if Left_dis < Dis_inf % if minimum left horizontal distance is less than image width
    TmpLeftPts = Left_pts; % set TempLeftPts to left points
else
    TmpLeftPts = zeros(4, 1); %else, set to zeros
end
if Right_dis < Dis_inf % if minimum right horizontal distance is less than image width
    TmpRightPts = Right_pts; % set TempRightPts to right points
else
    TmpRightPts = zeros(4, 1);  %else, set to zeros
end
TwoLanes = int32([TmpLeftPts TmpRightPts]); % 4 x 2 matrix; 1st col left pts, 2nd col right pts
% Check whether both lanes are valid
Check1 = (TwoLanes(1,:) ~= TwoLanes(3,:)) | ...
         (TwoLanes(2,:) ~= TwoLanes(4,:)); % check if y's not equal OR x's not equal => 1 x 2 logical array
Check2 = (abs(TwoLanes(1,:) - TwoLanes(3,:)) + ...
          abs(TwoLanes(2,:) - TwoLanes(4,:))) >= 10; % check if (diff in y's + diff in x's) big enough => 1x2 logical array
TwoValidLanes = (Left_dis <= Dis_inf) && (Right_dis <= Dis_inf) && ...
                 all((TwoLanes(1,:)>=0) & Check1 & Check2); % check distances < width, y's > 0, 1st 2 checks passed => logical 1 or 0

Diswarn = Dis_inf * 0.4; % Distance threshold for departure warning - EDIT TO CONTROL DEPARTURE WARNING SENSITIVITY
                            % For smaller lanes, decrease this percentage for better performance
if Left_dis < Diswarn && Left_dis <= Right_dis % if left lane distance from center less than 40% width and closer to left lane than right
    RawMsg = 2;
elseif Right_dis < Diswarn && Left_dis > Right_dis % if right lane distance from center less than 40% width and closer to right lane than left
    RawMsg = 0;
else
    RawMsg = 1; % both lanes are more than 40% of width away from center
end
% Meaning of Raw Masseage: 0 = Right lane departure,
%                          1 = Normal driving, 2 = Left lane departure

% The following code combines left-right departure to left departure and
% right-left departure to right departure. It utilizes the fact that there
% must be at least 4 frames of normal driving between a left departure
% warning and a right departure warning.
NumNormalDriving = NumNormalDriving + (RawMsg == 1); % increment NumNormalDriving when no departure detected
RawMsg = int8(RawMsg);
if RawMsg == int8(1) || NumNormalDriving >= 4 % if currently normal driving or at least 4 previous frames of normal driving
    OutMsg = RawMsg; % copy raw message to out message
end % else keep old OutMsg

if RawMsg ~= int8(1) % if not currently normal driving
    NumNormalDriving = 0; % set NumNormalDriving to 0
end

TwoLanes = TwoLanes([2 1 4 3], :);  % reset to [x1 y1 x2 y2]' format
