VR1 = vision.VideoFileReader('rawCompVideoLeft.avi');
j= 52;
i = 1;
while(~isDone(VR1))
frame = step(VR1);
if mod(i, 100) == 50
    imwrite(frame, [userpath '\trainingImages\image' num2str(j) '.png']);
    j = j + 1;
end
i = i + 1;
end