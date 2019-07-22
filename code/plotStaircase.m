function lineHandle = plotStaircase(axisAcuityData, varargin)
% Plots the contents of axisAcuityData as a staircase for one location
%
% Syntax:
%   plotSingleStaircase = plotStaircase(axisAcuityData)
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
    plotStaircase(axisAcuityData, 'showChartJunk', true);
%}



%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = false;

% Required
p.addRequired('axisAcuityData',@isstruct);

% Optional params
p.addParameter('posX',10,@isscalar);
p.addParameter('posY',0,@isscalar);
p.addParameter('showChartJunk',true,@islogical);


%% Parse and check the parameters
p.parse(axisAcuityData, varargin{:});


%% Main 

% Find the indices in axisAcuityData with stimuli at the specified location
% on the screen in degrees.
idx = and((axisAcuityData.posY == p.Results.posY), (axisAcuityData.posX == p.Results.posX));

% Plot the data and retain the handle to the plot line
lineHandle = plot(1:sum(idx), axisAcuityData.cyclesPerDeg(idx));

% Hide or show plot label elements under the control of showChartJunk
if p.Results.showChartJunk
    xlabel('Trial number');
    ylabel('Spatial freq [cycles/deg]');
else
    axis off
end

end
