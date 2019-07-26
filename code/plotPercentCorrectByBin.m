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
%  'showChartJunk'        - Boolean. Controls if axis labels, tick marks,
%                           etc are displayed.
%
% Outputs:
%   threshVal             - Scalar. The stimulus value, in cycles/deg,
%                           estimated to produce 50% accuracy.
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
p.addParameter('showChartJunk',true,@islogical);
p.addParameter('plotSymbolMaxSize',100,@isscalar);
p.addParameter('xDomain',[0.75 40],@isnumeric);
p.addParameter('calcThreshCI',false,@islogical);
p.addParameter('nBoots',1000,@isscalar);


%% Parse and check the parameters
p.parse(axisAcuityData, position, varargin{:});


%% Main 

% Get bins
[binCenters,nCorrect,nTrials] = binTrials(axisAcuityData, position, varargin{:});

% Get the palamedes fit to the data
if p.Results.calcThreshCI
    [modelFitFunc, paramsValues, paramsValuesSD]  = fitPalamedes(axisAcuityData, position, 'calcSD', true);
else
    [modelFitFunc, paramsValues, paramsValuesSD]  = fitPalamedes(axisAcuityData, position, 'calcSD', false);
end

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
threshVal = findThresh(paramsValues, modelFitFunc);
plot([threshVal threshVal],[0 0.5],'--k');
plot(threshVal,0.5,'xk');

% Boot-strap resample to get a confidence interval on the threshold
if p.Results.calcThreshCI
    threshValBoots = nan(1,1000);
    for bb=1:p.Results.nBoots
        threshValBoots(bb)=findThresh(normrnd(paramsValues, paramsValuesSD),modelFitFunc);
    end
    threshValSort = sort(threshValBoots);
    threshValCI(1) = threshValSort(round(sum(~isnan(threshValSort))*0.05));
    threshValCI(2) = threshValSort(round(sum(~isnan(threshValSort))*0.95));
    
    plot(threshValCI,[0.5 0.5],'-r');
end

% Reverse the x-axis so that performance gets better to the right
set(gca,'xscale','log')
set(gca, 'XDir','reverse')

% Set the plot limits
pbaspect([3 1 1])
ylim([0 1]);
xlim(p.Results.xDomain);

% Hide or show plot label elements under the control of showChartJunk
if p.Results.showChartJunk
    ylabel('Proportion correct');
    xlabel('Log spatial freq [cycles/deg]');
else
    axis off
end

end


function threshVal = findThresh(paramsValues, modelFitFunc)
myObj = @(x) (modelFitFunc(paramsValues,x)-0.5);
options = optimset('Display','off');
threshVal = fzero(myObj,10,options);
end
