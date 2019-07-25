function plotHandle = plotPercentCorrectByBin(axisAcuityData, varargin)
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
%       posX              - Measured by degrees of eccentricity along the x
%                           axis
%       posY              - Measured by degrees of eccentricity along the y
%                           axis
%       cyclesPerDeg      - Carrier spatial frequency of stimulus cyc/deg
%       response          - Hit -- 1 Miss -- 0
%
% Optional key/value pairs:
%  'posX', 'posY'         - Scalar(s). The x and y position in degrees of
%                           the stimuli to be plotted.
%  'showChartJunk'        - Boolean. Controls if axis labels, tick marks,
%                           etc are displayed.
%
% Outputs:
%   lineHandle            - handle to line object. The plot line itself.
%                          
% History:
%    07/19/19  jen       Created module from previous code
%    07/22/19  jen, gka  Edited a bit
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

% Optional params
p.addParameter('posX',0,@isscalar);
p.addParameter('posY',10,@isscalar);
p.addParameter('showChartJunk',true,@islogical);


%% Parse and check the parameters
p.parse(axisAcuityData, varargin{:});


%% Main 

% Get bins
[binCenters,nCorrect,nTrials] = binTrials(axisAcuityData, varargin{:});

% Plot the data and retain the handle to the plot symbols
plotHandle = scatter(binCenters, nCorrect./nTrials,nTrials*10,'red','filled');

% Reverse the x-axis so that performance gets better to the right
set(gca,'xscale','log')
set(gca, 'XDir','reverse')

% Set the plot limits
pbaspect([2 1 1])
ylim([0 1]);
xlim([0.75, 40]);

% Hide or show plot label elements under the control of showChartJunk
if p.Results.showChartJunk
    ylabel('Proportion correct');
    xlabel('Log spatial freq [cycles/deg]');
else
    axis off
end

end
