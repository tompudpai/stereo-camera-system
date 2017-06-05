function frameOut = overlay(frame, idx, lines, peds, signs,...
                vehicles, showText)
%% Overlay lines and view results
% this section may need to be changed if you change line struct
% xy = zeros(100,4);

frameOut = frame;
if ~isempty(lines)

%     for lidx = 1:length(lines)
%         %xy(lidx,:) = [(lines(lidx).point1 + [0 nr*7/16]) (lines(lidx).point2 + [0 nr*7/16])];  
%         xy(lidx,:) = [lines(lidx).point1 lines(lidx).point2];  
%         frameOut = insertShape(frame,'Line',xy(lidx,:),'Color',[0 255 0],'LineWidth',1);
%         %frame = frameLines(:,:,1:3);
%     end
    % lines in [x1 y1 x2 y2]' x 2 format
    if idx >= 5
        frameOut = insertShape(frameOut,'Line',lines',...
                'Color',{'blue','blue'}, 'LineWidth', 2);
    end

end

%% Overlay detected people
% frameOut = insertShape(frameOut,'rectangle',peds,'Color','blue');
% if showText
%     % Label the pedestrian ID
%     for p = 1:size(peds,1)
%         pos = [peds(p,1) peds(p,2)+peds(p,4)];
%         frameOut = insertText(frameOut,pos,['Ped_' num2str(pedIdx(p))],...
%             'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','blue');
%     end
% end

numPeds = size(peds.boxes,1);
if numPeds > 0
    
    frameOut = insertShape(frameOut,'rectangle',peds.boxes,'Color','blue','LineWidth',3);
    
    if showText
        
        id_string = cell(numPeds, 1);
        dist_string = cell(numPeds, 1);
        for p = 1:numPeds
            id_string{p} = ['Ped_' num2str(peds.idx(p))];
            dist_string{p} = [num2str(peds.dist(p), '%.2f') ' m'];
        end
        
        % Label the pedestrian IDs and distances
        pos2 = [peds.boxes(:,1) peds.boxes(:,2)-24];
        pos1 = pos2 - [0 24];
        frameOut = insertText(frameOut,pos1, id_string,...
            'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','blue');
        frameOut = insertText(frameOut,pos2, dist_string, ...
            'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','blue');

    end
end

%% Overlay detected signs
% if ~isempty(signs)
%     for sidx = 1:size(signs,2)
%         frameOut = insertShape(frameOut,'rectangle',signs(sidx).boxes);
%         % ADD labels
%     end
% end

numSigns = size(signs.boxes,1);
if numSigns > 0
    
    frameOut = insertShape(frameOut,'rectangle',signs.boxes,'Color','white','LineWidth',3);
    
    if showText

        id_string = cell(numSigns, 1);
        dist_string = cell(numSigns, 1);
        for s = 1:numSigns
            if(signs.label(s) == 1)
                id_string{s} = ['StopSign_' num2str(signs.idx(s))];
            elseif (signs.label(s) == 2)
                id_string{s} = ['YieldSign_' num2str(signs.idx(s))];
            else 
                id_string{s} = ['SpeedLimitSign_' num2str(signs.idx(s))];
            end
            dist_string{s} = [num2str(signs.dist(s), '%.2f') ' m'];
        end
        
        % Label the sign labels, IDs, and distances
        pos2 = [signs.boxes(:,1) signs.boxes(:,2)-24];
        pos1 = pos2 - [0 24];
        frameOut = insertText(frameOut,pos1, id_string,...
            'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','white');
        frameOut = insertText(frameOut,pos2, dist_string,...
            'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','white');
    end
end

    
% numStopSigns = size(signs.stopBoxes,1);
% if numStopSigns > 0
%     
%     frameOut = insertShape(frameOut,'rectangle',signs.stopBoxes,'Color','white');
%     
%     if showText
%     %     frameOut = insertObjectAnnotation(frameOut,'rectangle',signs,'Stop Sign','Color','white');
%         % Label the sign ID
% %         for s = 1:numSigns
% %             pos = [signs(s,1) signs(s,2)+signs(s,4)];
% %             frameOut = insertText(frameOut,pos, ['StopSign_' num2str(signs(s).idx)],...
% %                 'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','white');
% %         end
%         id_string = cell(numStopSigns, 1);
%         dist_string = cell(numStopSigns, 1);
%         for s = 1:numStopSigns
%             id_string{s} = ['StopSign_' num2str(signs.stopIdx(s))];
%             dist_string{s} = [num2str(signs.stopDist(s), '%.2f') ' m'];
%         end
%         
%         % Label the sign labels, IDs, and distances
%         pos1 = [signs.stopBoxes(:,1) signs.stopBoxes(:,2)+signs.stopBoxes(:,4)];
%         pos2 = pos1 + [0 24];
%         frameOut = insertText(frameOut,pos1, id_string,...
%             'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','white');
%         frameOut = insertText(frameOut,pos2, dist_string,...
%             'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','white');
% 
%     end
% end
% % pos = [signs(:,1) signs(:,2)+signs(:,4)];
% % frameOut = insertObjectAnnotation(frameOut,'rectangle',signs,'Stop Sign','Color','white');
% 
% numYieldSigns = size(signs.yieldBoxes,1);
% if numYieldSigns > 0
%     
%     frameOut = insertShape(frameOut,'rectangle',signs.yieldBoxes,'Color','white');
%     
%     if showText
% 
%         id_string = cell(numYieldSigns, 1);
%         dist_string = cell(numYieldSigns, 1);
%         for s = 1:numYieldSigns
%             id_string{s} = ['YieldSign_' num2str(signs.yieldIdx(s))];
%             dist_string{s} = [num2str(signs.yieldDist(s), '%.2f') ' m'];
%         end
%         
%         % Label the sign labels, IDs, and distances
%         pos1 = [signs.yieldBoxes(:,1) signs.yieldBoxes(:,2)+signs.yieldBoxes(:,4)];
%         pos2 = pos1 + [0 24];
%         frameOut = insertText(frameOut,pos1, id_string,...
%             'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','white');
%         frameOut = insertText(frameOut,pos2, dist_string,...
%             'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','white');
% 
%     end
% end
% 
% numSLSigns = size(signs.SLBoxes,1);
% if numSLSigns > 0
%     
%     frameOut = insertShape(frameOut,'rectangle',signs.SLBoxes,'Color','white');
%     
%     if showText
% 
%         id_string = cell(numSLSigns, 1);
%         dist_string = cell(numSLSigns, 1);
%         for s = 1:numSLSigns
%             id_string{s} = ['SLSign_' num2str(signs.SLIdx(s))];
%             dist_string{s} = [num2str(signs.SLDist(s), '%.2f') ' m'];
%         end
%         
%         % Label the sign labels, IDs, and distances
%         pos1 = [signs.SLBoxes(:,1) signs.SLBoxes(:,2)+signs.SLBoxes(:,4)];
%         pos2 = pos1 + [0 24];
%         frameOut = insertText(frameOut,pos1, id_string,...
%             'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','white');
%         frameOut = insertText(frameOut,pos2, dist_string,...
%             'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','white');
% 
%     end
% end

%% Overlay detected vehicles

numVeh = size(vehicles.boxes,1);
if numVeh > 0
    % Mark car bounding boxes in green initially
    frameOut = insertShape(frameOut,'rectangle',vehicles.boxes, 'Color', 'green','LineWidth',3);
    textColor = cell(numVeh,1);
    for v = 1:numVeh
        textColor{v} = 'green';
        if vehicles.pos(v) == 2 
            if vehicles.dist(v) < 20
                frameOut = insertShape(frameOut,'rectangle',vehicles.boxes(v,:),'Color','red','LineWidth',3);
                textColor{v} = 'red';
            else
                frameOut = insertShape(frameOut,'rectangle',vehicles.boxes(v,:),'Color','yellow','LineWidth',3);
                textColor{v} = 'yellow';
            end
        end
    end
    
    if showText
        % Label the vehicle IDs and distances
        id_string = cell(numVeh, 1);
        dist_string = cell(numVeh, 1);
        for v = 1:numVeh
            id_string{v} = ['Veh_' num2str(vehicles.idx(v))];
            dist_string{v} = [num2str(vehicles.dist(v), '%.2f') ' m'];
        end
        pos2 = [vehicles.boxes(:,1) vehicles.boxes(:,2)-24];
        pos1 = pos2 - [0 24];
        frameOut = insertText(frameOut,pos1, id_string,...
            'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor',textColor);
        frameOut = insertText(frameOut,pos2, dist_string,...
            'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor',textColor);
%         for v = 1:numVeh
%     %         dist_string = sprintf('Distance: %.2f m', vehicles.dist(v));   
%             dist_string = ['Distance: ' num2str(vehicles.dist(v), '%.2f') ' m'];
%             pos = [vehicles.boxes(v,1) vehicles.boxes(v,2)+vehicles.boxes(v,4)];
%             frameOut = insertText(frameOut,pos, dist_string,'FontSize',14,'Font','Arial Bold','BoxOpacity',0.5,'BoxColor','yellow');
%     %         frameOut = insertObjectAnnotation(frameOut,'rectangle',vehicles.boxes(v,:),dist_string);
%         end
    end
end

end