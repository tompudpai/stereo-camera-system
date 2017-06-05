function [Rep_ref, Count_ref] = videolanematching(Rep_ref, Count_ref, ...
                                   MaxLaneNum, ExpLaneNum, Enable, Line, ...
                                   TrackThreshold, CountUpperThresh)
% VIDEOLANEMATCHING - Tracks the lane marker lines

% Rep_ref   = zeros(2, MaxLaneNum); % Stored lines (2 x 20 matrix of zeros initially)
% Count_ref = zeros(1, MaxLaneNum); % Count of each stored line (1 x 20 matrix of zeros initially)
% MaxLaneNum = 20; % Maximum number of lanes to store in the tracking repository.
% ExpLaneNum = 2;  % Maximum number of lanes to find in the current frame.
% TrackThreshold = 75; % Maximum allowable change of lane distance
%                      % metric between two frames. ADJUST THIS TO CONTROL
%                      HOW EASY LINES ARE DIFFERENTIATED IN THE REPOSITORY

% Line = [Rho(Idx1(:, 1)); Theta(Idx1(:, 2))]; % [peakRho1 peakRho2; peakTheta1 peakTheta2]
% Enable = [ones(1,Count1) zeros(1, ExpLaneNum-Count1)]; % [1 1] if 2 peaks identified, [1 0] if 1 peak identified, [0 0] if none identified

% % Minimum number of frames a lane must be detected to become a valid lane.
% frameFound = 5;
% % Maximum number of frames a lane can be missed without marking it invalid. 
% frameLost = 20;
% CountUpperThresh = frameFound + frameLost;     

% Lane matching
% Calculate the distances between the lines found in the current frame
% and those in the repository.
List = double(intmax('int16')) * ones(MaxLaneNum, ExpLaneNum); % create 20 x 2 matrix of values 32767
for i = 1:MaxLaneNum % for each of the 20 line pairs stored in tracking repository
    for j = 1:ExpLaneNum % for each of 2 possible lanes detected
        if Count_ref(i) > 0 && Enable(j) == 1 % if count of stored line > 0 and lane detected
            List(i, j) = abs(Line(1, j)' - Rep_ref(1,i)) + ...
                abs(Line(2, j)' - Rep_ref(2, i)) * 200; % listValue = abs(currentRho - storedRho) + abs(currentTheta-storedTheta)
        end
    end
end
% Find the best matches between the current lines and those in the
% repository.
%Match_dis  = intmax('int16')*ones(1, MaxLaneNum, 'int16');
Match_dis  = double(intmax('int16'))*ones(1, ExpLaneNum); % create 1 x 20 matrix of values 32767  ** CHANGE MaxLaneNum TO ExpLaneNum
Match_list = zeros(2, ExpLaneNum); % create 2 x 20 matrix of zeros ** CHANGE MaxLaneNum TO ExpLaneNum
% ^ Match_dis and Match_list sizes are too big. They only have to be 1 x 2 and 2 x 2 in size, respectively. 
% ^ Change MaxLaneNum to ExpLaneNum to fix this
for i = 1:ExpLaneNum % for each of 2 possible lanes detected
    if i > 1
        % Reset the row and column where the minimum element lies on.
        List(rowInd, :) = double(intmax('int16')) * ones(1, ExpLaneNum); % set row of matched lane to values 32767
        List(:, colInd) = double(intmax('int16')) * ones(MaxLaneNum, 1); % set col of matched lane to values 32767
    end
    % In the 1st iteration, find minimum element (corresponds to
    % best matching targets) in the distance matrix. Then, use the
    % updated distance matrix where the minimun elements and their
    % corresponding rows and columns have been reset.
    [Val, Ind]      = min(List(:)); % find value and index with minimum absolute difference in List
    [rowInd, colInd] = ind2sub(size(List), Ind); % convert index to (row, col) subscript format
    Match_dis(i)    = Val; % set column 1 or 2 of Match_dis to minimum difference value
    Match_list(:,i) = [rowInd colInd]'; % set column 1 or 2 of Match_list to [row col]'
end
% Update reference target list.
% If a line in the repository matches with an input line, replace
% it with the input one and increase the count number by one;
% otherwise, reduce the count number by one. The count number is
% then saturated.
Count_ref = Count_ref - 1; % reduce all counts in 1 x 20 matrix by 1
for i = 1:ExpLaneNum % for each of 2 possible lanes detected
    if Match_dis(i) > TrackThreshold % if the matched lines are different enough from best matches
        % Insert in an unused space in the reference target list
        NewInd = find(Count_ref < 0, 1); % find col index of next negative count in count_ref 1 x 20 matrix
        Rep_ref(:, NewInd) = Line(:, Match_list(2, i)); % set both rows at col index to current rho and theta
        Count_ref(NewInd) = Count_ref(NewInd) + 2; % increment count at new col index by 2
    else % if matched lines are considered close enough to best matches
        % Update the reference list
        Rep_ref(:, Match_list(1, i)) = Line(:, Match_list(2, i)); % set matched col of repository to current rho and theta
        Count_ref(Match_list(1, i)) = Count_ref(Match_list(1, i)) + 2; % increment count at matched col index by 2
    end
end
Count_ref(Count_ref < 0) = 0; % reset all negative counts to 0
Count_ref(Count_ref > CountUpperThresh) = CountUpperThresh; % set upper threshold to 25 = 5 min frames detected to be 
                                                            % considered valid + 20 max frames before marking invalid 
