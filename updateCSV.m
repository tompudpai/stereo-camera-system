% format vehicle data for output csv file

vehicleData = zeros(15,1);
if any(vehicles.boxes)
    vehPresent = vehicles.idx == (1:5); % ( 0 1 0 1 0) -> IDs 2 and 4 present
else
    vehPresent = zeros(1,5);
end
j = 1;
for i = 1:5
    vehicleData(3*i-2) = vehPresent(i); %Veh1ID
    if vehPresent(i)
        vehicleData(3*i-1) = vehicles.dist(j); %Veh1Dist
        vehicleData(3*i) = vehicles.pos(j); %Veh1LanePos(0|1|2|3)  
        j = j + 1;
    else
        vehicleData(3*i-1) = 0; 
        vehicleData(3*i) = 0; 
    end
end
    
% format ped data for output csv file
pedData = zeros(15,1);
if any(peds.boxes)
    pedPresent = peds.idx == (1:5);
else
    pedPresent = zeros(1,5);
end
j = 1;
for i = 1:5
    pedData(3*i-2) = pedPresent(i); %Ped1ID
    if pedPresent(i)
        pedData(3*i-1) = peds.dist(j); %Ped1Dist
        pedData(3*i) = peds.pos(j); %Ped1LanePos(0|1|2|3)  
        j = j + 1;
    else
        pedData(3*i-1) = 0; 
        pedData(3*i) = 0; 
    end
end

% format sign data for output csv file
signData = zeros(15,1);
if any(signs.boxes)
    signsPresent = signs.idx == (1:5); % ( 0 1 0 1 0) -> IDs 2 and 4 present
else
    signsPresent = zeros(1,5);
end
j = 1;
for i = 1:5
    signData(3*i-2) = signsPresent(i); %Sign1ID
    if signsPresent(i)
        signData(3*i-1) = signs.dist(j); %Sign1Dist
        signData(3*i) = signs.label(j); %Sign1LanePos(0|1|2|3)  
        j = j + 1;
    else
        signData(3*i-1) = 0; 
        signData(3*i) = 0; 
    end
end

% if iteration time within time interval
% time = 0.2
currentToc = toc;

currentTocDown = floor(currentToc) + floor((currentToc-floor(currentToc))*5)/5;
prevTocUp = floor(prevToc) + ceil((prevToc-floor(prevToc))*5)/5;
numEntries = (currentTocDown - prevTocUp)/0.2 + 1;

if numEntries > 0

    time = prevTocUp;

    for i=1:numEntries
        time = time + 0.2;
        M = [time; ...
        vehicleData; ...
        pedData; ...
        signData];
        dlmwrite(csvName,M','-append');
    end
end

prevToc = currentToc;

% M = [toc; % Time(s)
%         any(vehicles.idx == 1);%'Veh1ID,
%         vehicles.dist(1);%Veh1Distance(m),
%         1;%Veh1LanePos(0|1|2|3),'...
%         any(vehicles.idx == 1) >= 2;%'Veh2ID,
%         vehicles.dist(2);%Veh2Distance(m),
%         1;%Veh2LanePos(0|1|2|3),'...
%         any(vehicles.idx == 1) >= 3;%'Veh3ID,
%         vehicles.dist(3);%Veh3Distance(m),
%         1;%Veh3LanePos(0|1|2|3),'...
%         any(vehicles.idx == 1);%'Veh4ID,
%         vehicles.dist(4);%Veh4Distance(m),
%         1;%Veh4LanePos(0|1|2|3),'...
%         any(vehicles.idx == 1) >= 5;%'Veh5ID,
%         vehicles.dist(5);%Veh5Distance(m),
%         1;%Veh5LanePos(0|1|2|3),'...
%         1;%'Ped1ID,
%         1;%Ped1Distance(m),
%         1;%Ped1Pos(0|1|2|3),'...
%         1;%'Ped2ID,
%         1;%Ped2Distance(m),
%         1;%Ped2Pos(0|1|2|3),'...
%         1;%'Ped3ID,
%         1;%Ped3Distance(m),
%         1;%Ped3Pos(0|1|2|3),'...
%         1;%'Ped4ID,
%         1;%Ped4Distance(m),
%         1;%Ped4Pos(0|1|2|3),'...
%         1;%'Ped5ID,
%         1;%Ped5Distance(m),
%         1;%Ped5Pos(0|1|2|3),'...
%         1;%'Sign1ID,
%         1;%Sign1Distance(m),
%         1;%Sign1Type(0|1|2|3),'...
%         1;%'Sign2ID,
%         1;%Sign2Distance(m),
%         1;%Sign2Type(0|1|2|3),'...
%         1;%'Sign3ID,
%         1;%Sign3Distance(m),
%         1;%Sign3Type(0|1|2|3),'...
%         1;%'Sign4ID,
%         1;%Sign4Distance(m),
%         1;%Sign4Type(0|1|2|3),'...
%         1;%'Sign5ID,
%         1;%Sign5Distance(m),
%         1];%Sign5Type(0|1|2|3)'

%     dlmwrite(csvName,M','-append');