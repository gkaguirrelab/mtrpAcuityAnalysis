function [threshVal, threshValCI] = plotPercentCorrectByBin(axisAcuityData, position, varargin)
% Plots the contents of axisAcuityData as a staircase for one location
%
% Syntax:
%   lineHandle = plotPercentCorrectByBin(axisAcuityData)
%
% Description:
%   Uses the data structure axisAcuityData to create a graph of stimulus
%   carrier frequency (in cycles per degree) over time (measured by trial
%   number) in one location given by degrees in eccentricity on the X and Y
%   axis.
%
% Inputs:
%   axisAcuityData        - Structure, with the fields:
%       posX                - Measured by degrees of eccentricity along the
%                             x-axis
%       posY                - Measured by degrees of eccentricity along the
%                             y-axis
%       cyclesPerDeg        - Carrier spatial frequency of stimulus cyc/deg
%       response            - Hit -- 1 Miss -- 0
%   position              - Numeric or cell array. Each entry is a 1x2
%                           vector that provides the [x, y] position in
%                           degrees of the stimuli to be plotted.
%
% Optional key/value pairs:
%  'criterion'            - Scalar. The proportion correct for which the
%                           threhsold will be determined.
%  'plotSymbolMaxSize'    - Scalar. The plot symbols are scaled by the
%                           relative number of trials in that bin. This
%                           controls the maximum size of the plot symbols.
%  'xDomain'              - 1x2 vector. The x-axis minimum and maximum spatial
%                           frequency (in cycles per degree).
%  'calcThreshCI'         - Logical. Controls if the 95% confidence
%                           interval on the threshold is calculated and
%                           shown on the plot.
%  'nBoots'               - Scalar. The number of resamples used to
%                           calculate the CI.
%
% Outputs:
%   threshVal             - Scalar. The stimulus value, in cycles/deg,
%                           estimated to produce the criterion accuracy.
%   threshValCI           - 1x2 vector. The 95% CI around the threshVal. If
%                           calcThreshCI is set to false, this variable is
%                           returned as [nan nan].
% 
% Examples 
%{
    % Plot a location from the first mat file in the data directory
    dataBasePath = getpref('mtrpAcuityAnalysis','mtrpCompiledDataPath');
    tmp = dir(fullfile(dataBasePath,'*_axisAcuityData.mat'));
    dataFileName = fullfile(tmp(1).folder,tmp(1).name);
    load(dataFileName,'axisAcuityData')
    plotPercentCorrectByBin(axisAcuityData,[5 0]);
%}



%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = false;

% Required
p.addRequired('axisAcuityData',@isstruct);
p.addRequired('position', @(x)(isnumeric(x) | iscell(x)));

% Optional params
p.addParameter('criterion',0.67,@isscalar);
p.addParameter('plotSymbolMaxSize',50,@isscalar);
p.addParameter('xDomain',[0.75 40],@isnumeric);
p.addParameter('calcThreshCI',false,@islogical);
p.addParameter('nBoots',1000,@isscalar);
p.addParameter('showXLabel',true,@islogical);
p.addParameter('showYLabel',true,@islogical);


%% Parse and check the parameters
p.parse(axisAcuityData, position, varargin{:});


%% Main 

% Get bins
[binCenters,nCorrect,nTrials] = binTrials(axisAcuityData, position, varargin{:});

% Handle the case of no data
if all(isnan(binCenters))
    threshVal = nan;
    threshValCI = [nan nan];
    return
end

% Get the palamedes fit to the data. Pass the value of the calcThreshCI
% parameter to set if the SD of the parameters should be obtained.
[modelFitFunc, paramsValues, paramsValuesSD]  = ...
    fitPalamedes(axisAcuityData, position, 'calcSD', p.Results.calcThreshCI);

% Figure out how big to make the symbols
symbolSize = 100./(nTrials./max(nTrials));

% Plot the data and retain the handle to the plot symbols
scatter(binCenters, nCorrect./nTrials, symbolSize,'red','filled');

% Add a line at chance
hold on
plot(p.Results.xDomain,[0.5,0.5],':b');

% Add the logisitic fit
fineSupport = logspace(log10(p.Results.xDomain(1)),log10(p.Results.xDomain(2)));
plot(fineSupport,modelFitFunc(paramsValues, fineSupport),'-k');

% Determine the 50% performance point
threshVal = findThresh(paramsValues, modelFitFunc, p.Results.criterion);
plot([threshVal threshVal],[0 p.Results.criterion],'--k');
plot(threshVal,p.Results.criterion,'xk');

% Boot-strap resample to get a confidence interval on the threshold
if p.Results.calcThreshCI
    threshValBoots = nan(1,1000);
    for bb=1:p.Results.nBoots
        threshValBoots(bb)=findThresh(normrnd(paramsValues, paramsValuesSD),modelFitFunc, p.Results.criterion);
    end
    threshValSort = sort(threshValBoots);
    threshValCI(1) = threshValSort(round(sum(~isnan(threshValSort))*0.05));
    threshValCI(2) = threshValSort(round(sum(~isnan(threshValSort))*0.95));
    
    plot(threshValCI,[p.Results.criterion p.Results.criterion],'-r','LineWidth',2);
else
    threshValCI = [nan nan];
end

% Reverse the x-axis so that performance gets better to the right
set(gca,'xscale','log')
set(gca, 'XDir','reverse')

% Clean up and label
text(0.05,0.9,[num2str(sum(nTrials)) ' trials'],'Units','normalized')
if p.Results.showYLabel
    ylabel('Proportion correct');
end
if p.Results.showXLabel
    xlabel('Log spatial freq [cycles/deg]');
end
pbaspect([3 1 1])
ylim([0 1]);
xlim(p.Results.xDomain);

end


function threshVal = findThresh(paramsValues, modelFitFunc, criterion)
myObj = @(x) (modelFitFunc(paramsValues,x)-criterion);
options = optimset('Display','off');
threshVal = fzero(myObj,10,options);
end
