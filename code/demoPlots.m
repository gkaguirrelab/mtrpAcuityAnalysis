
load('data/Subject_AOSO_11060_axisAcuityData.mat');

positionSets = {...
    {[-2.5, 0],[2.5,0],[0,2.5],[0,-2.5]};...
    {[-5, 0],[5,0],[0,5],[0,-5]};...
    {[-10, 0],[10,0],[0,10],[0,-10]};...
    {[-20, 0],[20,0],[0,20],[0,-20]};...
    };

titleSets = {'2.5 degrees','5 degrees','10 degrees','20 degrees'};

for ii=1:length(positionSets)
    figure('NumberTitle', 'off', 'Name', titleSets{ii});
    subplot(2,1,1);
    plotStaircase(axisAcuityData, 'position',positionSets{ii});
    subplot(2,1,2);
    plotPercentCorrectByBin(axisAcuityData, 'position',positionSets{ii});
end

