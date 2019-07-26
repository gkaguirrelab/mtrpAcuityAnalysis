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
%  'position'             - Numeric or cell array. Each entry is a 1x2
%                           vector that provides the [x, y] position in
%                           degrees of the stimuli to be plotted.
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
    plotStaircase(axisAcuityData, 'posX', 5, 'posY',0);
%}



%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = false;

% Required
p.addRequired('axisAcuityData',@isstruct);

% Optional params
p.addParameter('position',[0,10], @(x)(isnumeric(x) | iscell(x)));
p.addParameter('showChartJunk',true,@islogical);


%% Parse and check the parameters
p.parse(axisAcuityData, varargin{:});


%% Main

% Find the indices in axisAcuityData with stimuli at the specified location
% on the screen in degrees.

if isnumeric(p.Results.position)
    position = {p.Results.position};
else
    position = p.Results.position;
end
idx = false(size(axisAcuityData.posX));
idxCorrect = false(size(axisAcuityData.posX));
idxIncorrect = false(size(axisAcuityData.posX));
idxNoResponse = false(size(axisAcuityData.posX));
for ii=1:length(position)
    thisPos = position{ii};
    idx(and(axisAcuityData.posX==thisPos(1), axisAcuityData.posY==thisPos(2)))=true;
    idxCorrect(and( idx, axisAcuityData.response==1)) = true;
    idxIncorrect(and( idx, axisAcuityData.response==0)) = true;
    idxNoResponse(and( idx, isnan(axisAcuityData.response))) = true;
end

% Set up the x-axis support
trialNumber = nan(1,length(idx));
trialNumber(idx) = 1:sum(idx);

% Plot the data and retain the handle to the plot line
lineHandle = semilogy(trialNumber(idx), axisAcuityData.cyclesPerDeg(idx),'-k','LineWidth',1);

% Add markers for correect and incorrect trials
hold on
semilogy(trialNumber(idxCorrect),axisAcuityData.cyclesPerDeg(idxCorrect),'o','MarkerEdgeColor','green',...
    'MarkerFaceColor','none','MarkerSize',10);
semilogy(trialNumber(idxIncorrect),axisAcuityData.cyclesPerDeg(idxIncorrect),'x','MarkerEdgeColor','red','MarkerSize',10);
semilogy(trialNumber(idxNoResponse),axisAcuityData.cyclesPerDeg(idxNoResponse),'s','MarkerEdgeColor','blue',...
    'MarkerFaceColor','blue','MarkerSize',10);

% Set the plot limits
pbaspect([2 1 1])
xlim([0.5, sum(idx)+0.5]);
ylim([0.75, 40]);

% Hide or show plot label elements under the control of showChartJunk
if p.Results.showChartJunk
    xlabel('Trial number');
    ylabel('Log spatial freq [cycles/deg]');
else
    axis off
end

end
