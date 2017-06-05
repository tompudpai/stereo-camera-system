clear

% VR1 = vision.VideoFileReader('Activity1_Signs_Left_CSULA.mp4');
% VR = vision.VideoFileReader('Activity1_Signs_Right_CSULA.mp4');
% VR = vision.VideoFileReader('CSULA_StereoCameraSystemTestRun_1.mp4');
% VR = vision.VideoFileReader([userpath '\Examples\rawCompVideoLeft.avi']);
% VR1 = vision.VideoFileReader([userpath '\Examples\rawCompVideoRight.avi']);
% VW1 = vision.VideoFileWriter('Activity1SignsClip.avi');
% VW = vision.VideoFileWriter('Activity1SignsClip2.avi');
% VW = vision.VideoFileWriter([userpath '\compClipObstruction.avi']);
% VW = vision.VideoFileWriter([userpath '\Examples\compClipTestLeft5.avi']);
% VW1 = vision.VideoFileWriter([userpath '\Examples\compClipTestRight5.avi']);
% VW = vision.VideoFileWriter([userpath '\compClipTestLeft2.avi']);
% VW1 = vision.VideoFileWriter([userpath '\compClipTestRight2.avi']);
% VW = vision.VideoFileWriter([userpath '\compClipTestLeft3.avi']);
% VW1 = vision.VideoFileWriter([userpath '\compClipTestRight3.avi']);
% VW = vision.VideoFileWriter([userpath '\compClipTestLeft4.avi']);
% VW1 = vision.VideoFileWriter([userpath '\compClipTestRight4.avi']);

% cam = webcam;

i = 1;
while (~isDone(VR))
% for i = 1:100
%     frame2 = snapshot(cam);
%     frame1 = step(VR1);
    frame = step(VR);
%     if i > 210 && i < 275 % peds
%     if i > 60  && i < 175 % cars
%     if i > 970 % signs
% if i >= 100 && i <= 400 % comp test part 1
% if i >= 600 && i <= 860 % comp test part 2
%     if i >= 860 && i <= 1280 % comp test part 3
%     if i >= 1280 && i <= 1680 % comp test part 4
    if i >= 2170 && i <= 2310
%         step(VW1, frame1);
%         step(VW,frame);
    end
    frameArray = uint8(frame(:)*255);
    dist(i) = var(double(frameArray)*100);
    color(i) = mean(double(frameArray)*100);
    i = i + 1;
end

clear VR1
clear VR2
clear VW1
clear VW