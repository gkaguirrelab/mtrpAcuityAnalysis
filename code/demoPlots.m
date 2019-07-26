
subjectIDs = {'11060','11089','11096'};

% Identify the data location and set up the stimulus properties
dataBasePath = getpref('mtrpAcuityAnalysis','mtrpCompiledDataPath');
titleSets = {'2.5 degrees','5 degrees','10 degrees','20 degrees'};
eccenVals = [2.5,5,10,20];
positionSets = {...
    {[-2.5, 0],[2.5,0],[0,2.5],[0,-2.5],[1.77,1.77],[-1.77,-1.77],[-1.77,1.77],[1.77,-1.77]};...
    {[-5, 0],[5,0],[0,5],[0,-5],[3.54,3.54],[-3.54,-3.54],[-3.54,3.54],[3.54,-3.54]};...
    {[-10, 0],[10,0],[0,10],[0,-10],[7.07,7.07],[-7.07,-7.07],[-7.07,7.07],[7.07,-7.07]};...
    {[-20, 0],[20,0],[0,20],[0,-20],[14.14,14.14],[-14.14,-14.14],[-14.14,14.14],[14.14,-14.14]};...
    };

% Set up a figure to hold the threshold results
threshFigHandle = figure('NumberTitle', 'off', 'Name', 'Threshold values across subjects');

% Loop over the subjects
for ss=1:length(subjectIDs)
    
    % Load the data for this subject
    dataFileName = fullfile(dataBasePath,['Subject_AOSO_',subjectIDs{ss},'_axisAcuityData.mat']);
    load(dataFileName,'axisAcuityData')
    
    % Loop over the sets of eccentricity positions
    threshVals = zeros(1,length(positionSets));
    for ii=1:length(positionSets)
        figure('NumberTitle', 'off', 'Name', [subjectIDs{ss} ' - ' titleSets{ii}]);
        subplot(2,1,1);
        plotStaircase(axisAcuityData, positionSets{ii});
        subplot(2,1,2);
        threshVals(ii) = plotPercentCorrectByBin(axisAcuityData, positionSets{ii});
    end
    
    % Plot this set of thresh vals
    figure(threshFigHandle);
    plot(eccenVals,threshVals,'o-');
    hold on
end

% Finish the figure
figure(threshFigHandle);
xlim([0 25]);
ylim([1 20]);
xlabel('Eccentricity [deg]');
ylabel('Stimulus threshold for 50% performance [cycles/deg]');
legend(subjectIDs)
