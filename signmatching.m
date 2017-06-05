function [Rep_ref, Count_ref, Label_ref] = signmatching(Rep_ref, Count_ref, Label_ref, ...
                                   MaxObjNum, bbox1, bbox2, bbox3, ...
                                   TrackThreshold, CountUpperThresh)
% SIGNMATCHING - Tracks the 3 different signs

% Sign matching
% Calculate the distances between the objects found in the current frame
% and those in the repository.
% CurObjNum = size(bbox1,1) + size(bbox2,1) + size(bbox3,1);
numObj1 = size(bbox1,1);
numObj2 = size(bbox2,1);
numObj3 = size(bbox3,1);
CurObjNum = numObj1 + numObj2 + numObj3;
List = double(intmax('int16')) * ones(MaxObjNum, CurObjNum); % create 30 x CurObjNum matrix of values 32767
for i = 1:MaxObjNum % for each of the 30 objects stored in tracking repository
    for j1 = 1:numObj1 % for each object detected
        if Count_ref(i) > 0  % if count of stored object > 0 and object detected
            List(i, j1) = sum(abs(bbox1(j1, :)' - Rep_ref(:,i))); %listValue = sum(abs(bbox - stored bbox)))
        end
    end
    for j2 = 1:numObj2
        if Count_ref(i) > 0  % if count of stored object > 0 and object detected
            List(i, j2 + numObj1) = sum(abs(bbox2(j2, :)' - Rep_ref(:,i))); %listValue = sum(abs(bbox - stored bbox)))
        end
    end
    for j3 = 1:numObj3
        if Count_ref(i) > 0  % if count of stored object > 0 and object detected
            List(i, j3 + numObj1 +numObj2) = sum(abs(bbox3(j3, :)' - Rep_ref(:,i))); %listValue = sum(abs(bbox - stored bbox)))
        end
    end
end
% Find the best matches between the current objects and those in the
% repository.
%Match_dis  = intmax('int16')*ones(1, MaxLaneNum, 'int16');
Match_dis  = double(intmax('int16'))*ones(1, CurObjNum); % create 1 x CurObjNum matrix of values 32767
Match_list = zeros(2, CurObjNum); % create 2 x CurObjNum matrix of zeros
% ^ Match_dis and Match_list sizes are too big. They only have to be 1 x 2 and 2 x 2 in size, respectively. 
% ^ Change MaxLaneNum to ExpLaneNum to fix this
for i = 1:CurObjNum % for each object detected
    if i > 1
        % Reset the row and column where the minimum element lies on.
        List(rowInd, :) = double(intmax('int16')) * ones(1, CurObjNum); % set row of matched lane to values 32767
        List(:, colInd) = double(intmax('int16')) * ones(MaxObjNum, 1); % set col of matched lane to values 32767
    end
    % In the 1st iteration, find minimum element (corresponds to
    % best matching targets) in the distance matrix. Then, use the
    % updated distance matrix where the minimun elements and their
    % corresponding rows and columns have been reset.
    [Val, Ind]      = min(List(:)); % find value and index with minimum absolute difference in List
    [rowInd, colInd] = ind2sub(size(List), Ind); % convert index to (row, col) subscript format
    Match_dis(i)    = Val; % set 1 column of range 1 to CurObjNum of Match_dis to minimum difference value
    Match_list(:,i) = [rowInd colInd]'; % set 1 column of range 1 to CurObjNum of Match_list to [row col]'
end
% Update reference target list.
% If a object in the repository matches with an input object, replace
% it with the input one and increase the count number by one;
% otherwise, reduce the count number by one. The count number is
% then saturated.
Count_ref = Count_ref - 1; % reduce all counts in 1 x 20 matrix by 1
for i = 1:CurObjNum % for each current object detected
    ObjIdx = Match_list(2,i); % find global object index of matched object
    if Match_dis(i) > TrackThreshold % if the matched lines are different enough from best matches
        % Insert in an unused space in the reference target list
        NewInd = find(Count_ref < 0, 1); % find col index of next negative count in count_ref 1 x 10 matrix
        if ObjIdx <= numObj1
            Rep_ref(:, NewInd) = bbox1(ObjIdx, :)'; % set 4 rows at col index of rep_ref to current bbox
            Label_ref(NewInd) = 1;
        elseif ObjIdx > numObj1 + numObj2
            Rep_ref(:, NewInd) = bbox3(ObjIdx-numObj1-numObj2, :)'; % set 4 rows at col index of rep_ref to current bbox
            Label_ref(NewInd) = 3;
        else
            Rep_ref(:, NewInd) = bbox2(ObjIdx-numObj1, :)'; % set 4 rows at col index of rep_ref to current bbox
            Label_ref(NewInd) = 2;
        end
        Count_ref(NewInd) = Count_ref(NewInd) + 2; % increment count at new col index by 2
    else % if matched lines are considered close enough to best matches
        % Update the reference list
        if ObjIdx <= numObj1
            Rep_ref(:, Match_list(1, i)) = bbox1(ObjIdx, :)'; % set matched col of repository to current bbox
            Label_ref(Match_list(1, i)) = 1;
        elseif ObjIdx > numObj1 + numObj2
            Rep_ref(:, Match_list(1, i)) = bbox3(ObjIdx-numObj1-numObj2, :)'; % set matched col of repository to current bbox
            Label_ref(Match_list(1, i)) = 3;
        else
            Rep_ref(:, Match_list(1, i)) = bbox2(ObjIdx-numObj1, :)'; % set matched col of repository to current bbox
            Label_ref(Match_list(1, i)) = 2;
        end
        Count_ref(Match_list(1, i)) = Count_ref(Match_list(1, i)) + 2; % increment count at matched col index by 2
    end
end
Count_ref(Count_ref < 0) = 0; % reset all negative counts to 0
Count_ref(Count_ref > CountUpperThresh) = CountUpperThresh; % set upper threshold to 12 = 2 min frames detected to be 
                                                            % considered valid + 10 max frames before marking invalid 
