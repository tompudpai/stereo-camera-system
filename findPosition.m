function pos = findPosition(boxes, num, polyRatio, thresholdRatio, nr, nc, tf, bf)

    pos = zeros(1, num);
    % create mask of polygon of current lane
    y3 = [tf*nr tf*nr bf*nr bf*nr tf*nr];
    x3 = [nc*polyRatio(1) polyRatio(2)*nc polyRatio(3)*nc polyRatio(4)*nc nc*polyRatio(1)];
    b1 = poly2mask(x3, y3, nr, nc);

    % create mask of bounding box
    for i=1:num
        x4 = [boxes(i,1) boxes(i,1)+boxes(i,3) boxes(i,1)+boxes(i,3) boxes(i,1) boxes(i,1)];
        y4 = [boxes(i,2) boxes(i,2) boxes(i,2)+boxes(i,4) boxes(i,2)+boxes(i,4) boxes(i,2)];
        b2 = poly2mask(x4, y4, nr, nc);
%         figure; imshow(b2)

        % find overlap between current lane polygon and bounding box
        b3 = b1 & b2;
        overlap = sum(sum(b3));
        ratio = overlap/sum(sum(b2));

        % categorize position based on overlap percentage
        if ratio >= thresholdRatio
            pos(i) = 2;
        elseif boxes(i,1) < nc/2
            pos(i) = 1;
        else
            pos(i) = 3;
        end
%         disp(['overlap: ' num2str(overlap) 'sum(sum(b2)): ' num2str(sum(sum(b2))) ' ratio: ' num2str(ratio) ' pos: ' num2str(pos(i))])
    end
end
    % position polygon testing
%         [nr, nc, ~] = size(frame);
%         r = [1 nr*tf_veh nc nr*(bf_veh-tf_veh)];
%         frame = insertShape(frame,'Rectangle',r);
%         polyRatio = [.41 .59 .75 .25];
%         Pts_poly = [nc*polyRatio(1) tf_veh*nr polyRatio(2)*nc tf_veh*nr polyRatio(3)*nc bf_veh*nr polyRatio(4)*nc bf_veh*nr];
%         frame = insertShape(frame,'FilledPolygon',Pts_poly,...
%                               'Color',[0 1 1],'Opacity',0.2);  