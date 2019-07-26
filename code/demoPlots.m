
load('../data/Subject_AOSO_11060_axisAcuityData.mat');

positionSets = {...
    {[-2.5, 0],[2.5,0],[0,2.5],[0,-2.5],[1.77,1.77],[-1.77,-1.77],[-1.77,1.77],[1.77,-1.77]};...
     {[-5, 0],[5,0],[0,5],[0,-5],[3.54,3.54],[-3.54,-3.54],[-3.54,3.54],[3.54,-3.54]};...
    {[-10, 0],[10,0],[0,10],[0,-10],[7.07,7.07],[-7.07,-7.07],[-7.07,7.07],[7.07,-7.07]};...
    {[-20, 0],[20,0],[0,20],[0,-20],[14.14,14.14],[-14.14,-14.14],[-14.14,14.14],[14.14,-14.14]};...
    };

titleSets = {'2.5 degrees','5 degrees','10 degrees','20 degrees'};

for ii=1:length(positionSets)
    figure('NumberTitle', 'off', 'Name', titleSets{ii});
    subplot(2,1,1);
    plotStaircase(axisAcuityData, positionSets{ii});
    subplot(2,1,2);
    plotPercentCorrectByBin(axisAcuityData, positionSets{ii});
end

