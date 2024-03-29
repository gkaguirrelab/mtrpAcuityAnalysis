function plotStaircase(axisAcuityData, position, varargin)
% Plots the contents of axisAcuityData as a staircase for one location
%
% Syntax:
%   plotStaircase(axisAcuityData, position)
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
    subjectID = '11096';
    x = 10; y = 0;
    dataBasePath = getpref('mtrpAcuityAnalysis','mtrpCompiledDataPath');
    dataFileName =  fullfile(dataBasePath,['Subject_AOSO_' subjectID '_axisAcuityData.mat']);
    load(dataFileName,'axisAcuityData')
    figure
    plotStaircase(axisAcuityData,[20 0]);
    title(['AOSO-' subjectID ', [x=' num2str(x) ', y=', num2str(y) ']']);
%}



%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = false;

% Required
p.addRequired('axisAcuityData',@isstruct);
p.addRequired('position', @(x)(isnumeric(x) | iscell(x)));

% Optional params
p.addParameter('posMatchTolerance',0.1, @isscalar);
p.addParameter('showChartJunk',true,@islogical);


%% Parse and check the parameters
p.parse(axisAcuityData, position, varargin{:});


%% Main

%% Obtain the vector of responses for this position
% Find the indices in axisAcuityData with stimuli at the specified location
% on the screen in degrees.
idx = getIndicies(axisAcuityData, position, varargin{:});
idxCorrect = false(size(axisAcuityData.posX));
idxIncorrect = false(size(axisAcuityData.posX));
idxNoResponse = false(size(axisAcuityData.posX));
idxCorrect(and( idx, axisAcuityData.response==1)) = true;
idxIncorrect(and( idx, axisAcuityData.response==0)) = true;
idxNoResponse(and( idx, isnan(axisAcuityData.response))) = true;
    
% Set up the x-axis support
trialNumber = nan(1,length(idx));
trialNumber(idx) = 1:sum(idx);

% Plot the data and retain the handle to the plot line
semilogy(trialNumber(idx), axisAcuityData.cyclesPerDeg(idx),'-k','LineWidth',1);

% Add markers for correect and incorrect trials
hold on
semilogy(trialNumber(idxCorrect),axisAcuityData.cyclesPerDeg(idxCorrect),'o','MarkerEdgeColor','green',...
    'MarkerFaceColor','none','MarkerSize',10);
semilogy(trialNumber(idxIncorrect),axisAcuityData.cyclesPerDeg(idxIncorrect),'x','MarkerEdgeColor','red','MarkerSize',10);
semilogy(trialNumber(idxNoResponse),axisAcuityData.cyclesPerDeg(idxNoResponse),'s','MarkerEdgeColor','blue',...
    'MarkerFaceColor','blue','MarkerSize',10);

% Set the plot limits
pbaspect([3 1 1])
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
