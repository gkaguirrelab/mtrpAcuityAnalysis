function foo = fitPalamedes(axisAcuityData, varargin)
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
% Examples 
%{
    % Plot a location from the first mat file in the data directory
    dataBasePath = getpref('mtrpAcuityAnalysis','mtrpCompiledDataPath');
    tmp = dir(fullfile(dataBasePath,'*_axisAcuityData.mat'));
    dataFileName = fullfile(tmp(1).folder,tmp(1).name);
    load(dataFileName,'axisAcuityData')
    plotPercentCorrectByBin(axisAcuityData, 'showChartJunk', true);
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


%% Obtain the vector of responses for this position
% Find the indices in axisAcuityData with stimuli at the specified location
% on the screen in degrees.
idx = and(axisAcuityData.posY == p.Results.posY, axisAcuityData.posX == p.Results.posX);
values = axisAcuityData.cyclesPerDeg(idx);
responses = axisAcuityData.response(idx);



% Palamedes fit
%
% Fit with Palemedes Toolbox.  The parameter constraints match the psignifit parameters above. Again, some
% thought is required to initialize reasonably.  The threshold parameter is reasonably taken to be in the
% range of the comparison stimuli, where here 0 means that the comparison is the same as the test.  The 
% second parameter should be on the order of 1/2, so we just hard code that.  As with Y/N, really want to 
% plot the fit against the data to make sure it is reasonable in practice.

% Define what psychometric functional form to fit.
%
% Alternatives: PAL_Gumbel, PAL_Weibull, PAL_CumulativeNormal, PAL_HyperbolicSecant
PF = @PAL_Weibull;                  

% The first two parameters of the Weibull define its shape.
%
% The third is the guess rate, which determines the value the function
% takes on at x = 0.  For TAFC, this should be locked at 0.5.
%
% The fourth parameter is the lapse rate - the asymptotic performance at 
% high values of x.  For a perfect subject, this would be 0, but sometimes
% subjects have a "lapse" and get the answer wrong even when the stimulus
% is easy to see.  We can search over this, but shouldn't allow it to take
% on unreasonable values.  0.05 as an upper limit isn't crazy.
%
% paramsFree is a boolean vector that determins what parameters get
% searched over. 1: free parameter, 0: fixed parameter
paramsFree = [1 1 0 1];  

% Initial guess.  Setting the first parameter to the middle of the stimulus
% range and the second to 1 puts things into a reasonable ballpark here.
paramsValues0 = [mean(comparisonStimuli'-testStimulus) 1 0.5 0.01];

% This puts limits on the range of the lapse rate
lapseLimits = [0 0.05];

% Set up standard options for Palamedes search
options = PAL_minimize('options');

% Do the search to get the parameters
[paramsValues] = PAL_PFML_Fit(...
    values',responses',ones(size(responses')), ...
    paramsValues0,paramsFree,PF,'searchOptions',options,'lapseLimits',lapseLimits);

probCorrFitStair = PF(paramsValues,comparisonStimuliFit'-testStimulus);
threshPalStair = PF(paramsValues,thresholdCriterionCorrect,'inverse');

end
