%% Train cascade object detectors for signs

% Allow writing in directory
fileattrib('.','+w','','s')

    %% Create a sign detector 
    % DEFINE sign detector
    % Load positive samples.
    load('stopSignsAndCars.mat');
    load('yieldROIs3.mat');
    load('speedlimitROIs3.mat');
    load('blackCarROI.mat');
%%
% Select the bounding boxes for stop signs from the table.
positiveInstances = stopSignsAndCars(:,1:2);

 %%
% Add the image directory to the MATLAB path.
% imDir = fullfile(matlabroot,'toolbox','vision','visiondata',...
%     'stopSignImages');
imDirStop = fullfile(userpath,'stopSignImages');
imDirYield = fullfile(userpath,'yieldsigns');
imDirSL = fullfile(userpath,'sl');
imDirBlack = fullfile(userpath,'/trainingImages/black car');
addpath(imDirStop);
addpath(imDirYield);
addpath(imDirSL);
addpath(imDirBlack);
%%
% Specify the foler for negative images.
% negativeFolder = fullfile(matlabroot,'toolbox','vision','visiondata',...
%     'nonStopSigns');
negativeFolderStop = fullfile(userpath,'nonStopSigns');
negativeFolderYield = fullfile(userpath,'nonYieldSigns');
negativeFolderSL = fullfile(userpath,'nonSLSigns');
negativeFolderBlack = fullfile(userpath,'nonBlack');
%%
% Create an |imageDatastore| object containing negative images.
negativeImagesStop = imageDatastore(negativeFolderStop);
negativeImagesYield = imageDatastore(negativeFolderYield);
negativeImagesSL = imageDatastore(negativeFolderSL);
negativeImagesBlack = imageDatastore(negativeFolderBlack);

%%
% Train a cascade object detector called 'stopSignDetector.xml'
% using HOG features.
% NOTE: The command can take several minutes to run.
trainCascadeObjectDetector('stopSignDetector3.xml',positiveInstances, ...
    negativeFolderStop,'FalseAlarmRate',0.1,'NumCascadeStages',5);
trainCascadeObjectDetector('yieldSignDetector3.xml',yield, ...
    negativeFolderYield,'FalseAlarmRate',0.1,'NumCascadeStages',5);
trainCascadeObjectDetector('speedLimitSignDetector3.xml',speedlimit, ...
    negativeFolderSL,'FalseAlarmRate',0.1,'NumCascadeStages',5);
trainCascadeObjectDetector('blackCarDetector3.xml',blackCar, ...
    negativeFolderBlack,'FalseAlarmRate',0.05,'NumCascadeStages',5);%,'TruePositiveRate',0.997);

%%
% Remove the image directory from the path.
rmpath(imDirStop);
rmpath(imDirYield);
rmpath(imDirSL);
rmpath(imDirBlack);