function plotHandle = plotPercentCorrectByBin(axisAcuityData, position, varargin)
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
%   lineHandle            - handle to line object. The plot line itself.
% 
% Examples 
%{
    % Plot a location from the first mat file in the data directory
    dataBasePath = getpref('mtrpAcuityAnalysis','mtrpCompiledDataPath');
    tmp = dir(fullfile(dataBasePath,'*_axisAcuityData.mat'));
    dataFileName = fullfile(tmp(1).folder,tmp(1).name);
    load(dataFileName,'axisAcuityData')
    plotPercentCorrectByBin(axisAcuityData, 'posX', 5, 'posY',0);
%}



%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = false;

% Required
p.addRequired('axisAcuityData',@isstruct);
p.addRequired('position', @(x)(isnumeric(x) | iscell(x)));

% Optional params
p.addParameter('showChartJunk',true,@islogical);
p.addParameter('plotSymbolMaxSize',100,@isscalar);
p.addParameter('xDomain',[0.75 40],@isscalar);


%% Parse and check the parameters
p.parse(axisAcuityData, position, varargin{:});


%% Main 

% Get bins
[binCenters,nCorrect,nTrials] = binTrials(axisAcuityData, position, varargin{:});

% Get the palamedes fit to the data
[paramValues, modelFitFunc]  = fitPalamedes(axisAcuityData, position);

% Figure out how big to make the symbols
symbolSize = 100./(nTrials./max(nTrials));

% Plot the data and retain the handle to the plot symbols
plotHandle = scatter(binCenters, nCorrect./nTrials, symbolSize,'red','filled');

% Add a line at chance
hold on
plot(p.Results.xDomain,[0.5,0.5],':b');

% Add the logisitic fit
fineSupport = logspace(log10(p.Results.xDomain(1)),log10(p.Results.xDomain(2)));
plot(fineSupport,modelFitFunc(fineSupport),'-k');

% Add the threshold value to the plot
threshVal = 1/10.^paramValues(1);
plot([threshVal threshVal],[0 modelFitFunc(threshVal)],'--k');
plot([p.Results.xDomain(2) threshVal],[modelFitFunc(threshVal) modelFitFunc(threshVal)],'--k');
plot(threshVal,modelFitFunc(threshVal),'xk');

% Reverse the x-axis so that performance gets better to the right
set(gca,'xscale','log')
set(gca, 'XDir','reverse')

% Set the plot limits
pbaspect([2 1 1])
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
