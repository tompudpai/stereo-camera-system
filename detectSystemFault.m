function sysFaultStruct = detectSystemFault(frameL, frameR, obstructedThreshold, sysFaultOn)

% Detect system fault (whether or not a camera is obstructed)

if sysFaultOn

    %% Calculate variance of frames from each camera
    
    leftFault = 0;
    rightFault = 0;
    
    % reshape frames from matrix format into single vector
    frameL = frameL(:);
    frameR = frameR(:);
    
    % calculate variances of frames
%     varFrameL = var(double(frameL)*100);
% %     varFrameR = var(double(frameR)*100);
% %     varFrameL = var(var(double(rgb2gray(frameL))));
% %     varFrameR = var(var(double(rgb2gray(frameR))));
% 
%     if varFrameL < obstructedThreshold
%         leftFault = 1;
%     end
% 
%     if varFrameR < obstructedThreshold
%         rightFault = 1;
%     end

    % calculate average color intensity value of frames
    avgColorFrameL = mean(double(frameL)*100);
    avgColorFrameR = mean(double(frameR)*100);
%     disp(avgColorFrameL)
%     disp(avgColorFrameR)
    
   if avgColorFrameL < obstructedThreshold
        leftFault = 1;
    end

    if avgColorFrameR < obstructedThreshold
        rightFault = 1;
    end

    sysFaultStruct = struct('left', leftFault, 'right', rightFault);
else
    sysFaultStruct = struct('left', 0, 'right', 0);
end

%% Testing variance between an obstructed and unobstructed image 
% figure
% frame = imread('obscured.jpg');
% imshow(frame)
% 
% figure
% frame2 = imread('nonobscured.png');
% imshow(frame2)
% 
% varRGB1 = var(var(double(frame)))
% varRGB2 = var(var(double(frame2)));
% varRGB1./varRGB2
% 
% 
% varGray1 = var(var(double(rgb2gray(frame))))
% varGray2 = var(var(double(rgb2gray(frame2))));
% varGray1/varGray2


%% Testing variance: minimum variance found was 1.3*10^-5
% VR = vision.VideoFileReader('Activity1_Signs_Left_CSULA.mp4');
% VP = vision.DeployableVideoPlayer;
% 
% i = 1;
% while(~isDone(VR))
%     
%     frame = step(VR);
%     varFrameR(i) = var(var(double(frame(:,:,1))));
%     varFrameG(i) = var(var(double(frame(:,:,2))));
%     varFrameB(i) = var(var(double(frame(:,:,3))));
%     varFrameGray(i) = var(var(double(rgb2gray(frame))));
%     
%     frame = insertText(frame, [1 size(frame,1)-20], ['frame: ' num2str(i)]);
%     
%     step(VP, frame);
%     i = i + 1;
%     
% end
% 
% figure;
% plot(varFrameGray)
% title('Variance of frames (gray)')
% xlabel('time (t)')
% ylabel('distance (d)')
% 
% figure;
% plot(varFrameR)
% title('Variance of frames (R)')
% xlabel('time (t)')
% ylabel('distance (d)')
% figure;
% plot(varFrameG)
% title('Variance of frames (G)')
% xlabel('time (t)')
% ylabel('distance (d)')
% figure;
% plot(varFrameB)
% title('Variance of frames (B)')
% xlabel('time (t)')
% ylabel('distance (d)')

