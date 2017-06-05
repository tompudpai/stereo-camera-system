function structOut = createStruct()

%% this section might not be needed
% %% store results from each algorithm into a struct of results
% % create struct of 2 empty lines
% [X{1, 1:2}] = deal(0);
% field1 = 'point1';  value1 = zeros(1,2);
% field2 = 'point2';  value2 = zeros(1,2);
% field3 = 'theta';  value3 = X;
% field4 = 'rho';  value4 = X;
% lineStruct = struct(field1,value1,field2,value2,field3,value3,field4,value4);
% 
% % create struct of 10 empty pedestrian boxes
% pedBoxes = zeros(10,4);
% 
% % create struct of 10 empty sign boxes and labels
% [Y{1, 1:10}] = deal('');
% signBoxes = zeros(1,4);
% signStruct = struct('signBoxes', signBoxes,'signLabels',Y);
% 
% % create struct of 10 empty vehicle boxes, distances, and labels
% [Z{1, 1:10}] = deal('');
% vehicleBoxes = zeros(1,4);
% vehicleDist = zeros(1,1);
% vehicleStruct = struct('vehicleBoxes', vehicleBoxes,'vehicleDist',vehicleDist,'vehicleLabels',Z);

%% create a struct that combines results from each of the 4 algorithms
% structOut = struct('lines',lineStruct,'peds',pedBoxes,'signs',signStruct,'vehicles',vehicleStruct);

% this struct is a placeholder for the results from the 4 different algorithms
structOut = struct('lines',[],'peds',[],'signs',[],'vehicles',[]);

end