
subjectIDs = {'11060','11089','11080','11096'};
subjectColors = {'k','r','b','g'};
criterion = 0.67;
calcThreshCI = false;

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

% Set up a bit of jitter on the x-axis for the across-subject figure
if calcThreshCI
    jitterSize = 0.5;
else
    jitterSize = 0;
end
eccenJitter = jitterSize.*((1:length(subjectIDs))-(length(subjectIDs)/2));

% Loop over the subjects
for ss=1:length(subjectIDs)
    
    % Load the data for this subject
    dataFileName = fullfile(dataBasePath,['Subject_AOSO_',subjectIDs{ss},'_axisAcuityData.mat']);
    load(dataFileName,'axisAcuityData')

    % Set up a figure for this subject
    subjectFigHandle = figure('NumberTitle', 'off', 'Name', subjectIDs{ss});
    figPos = get(subjectFigHandle, 'Position');
    set(subjectFigHandle, 'Position', [figPos(1) figPos(2) 400 700]);
    

    % Loop over the sets of eccentricity positions
    threshVals = zeros(1,length(positionSets));
    threshValCIs = zeros(2,length(positionSets));
    for ii=1:length(positionSets)
        figure(subjectFigHandle);
        subplot(length(positionSets),1,ii);
        [threshVals(ii), threshValCIs(:,ii)] = plotPercentCorrectByBin(axisAcuityData, positionSets{ii}, ...
            'criterion', criterion, 'calcThreshCI', calcThreshCI, ...
            'showXLabel',ii==length(positionSets),'showYLabel',ii==1);
        title(titleSets{ii});
        % Add this point and an error bar to the across-subject plot
        figure(threshFigHandle);
        plot(eccenVals(ii)+eccenJitter(ss),threshVals(ii),['o',subjectColors{ss}]);
        hold on        
        plot([eccenVals(ii)+eccenJitter(ss) eccenVals(ii)+eccenJitter(ss)],threshValCIs(:,ii),['-',subjectColors{ss}],'LineWidth',1);
    end
    
    % Plot a line connecting these thresh vals
    figure(threshFigHandle);
    plot(eccenVals+eccenJitter(ss),threshVals,['-',subjectColors{ss}],'LineWidth',2);
    hold on
end

% Finish the figure
figure(threshFigHandle);
xlim([0 25]);
ylim([1 14]);
xlabel('Eccentricity [deg]');
ylabel('Stimulus threshold for 50% performance [cycles/deg]');
