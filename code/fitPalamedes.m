function [paramsValues, paramsValuesSD, pValue]  = fitPalamedes(axisAcuityData,varargin)
% Plots the contents of axisAcuityData as a staircase for one location
%
% Syntax:
%   foo = fitPalamedes(binCenters,nCorrect,nTrials,varargin)
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
%  'fitFunction'          - Function handle. Options include: @...
%                           PAL_Logistic, PAL_Gumbel, PAL_Weibull,
%                           PAL_Quick, PAL_logQuick, PAL_CumulativeNormal,
%                           PAL_HyperbolicSecant
%
% Outputs:
%   lineHandle            - handle to line object. The plot line itself.
%
% Examples
%{
%}



%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = false;

% Required
p.addRequired('axisAcuityData',@isstruct);

% Optional params
p.addParameter('position',[0,10], @(x)(isnumeric(x) | iscell(x)));
p.addParameter('calcSD',true, @islogical);
p.addParameter('calcPValue',true, @islogical);
p.addParameter('fitFunction',@PAL_Logistic, @(x) (isa(x,'function_handle')));


%% Parse and check the parameters
p.parse(axisAcuityData, varargin{:});


%% Main


% Get bins
[binCenters,nCorrect,nTrials] = binTrials(axisAcuityData, varargin{:});

% Express stimulus level as the reciprocal of log10 binCenters
stimulusLevel = log10(1./binCenters);

%Threshold and Slope are free parameters, guess and lapse rate are fixed
paramsFree = [1 1 1 0];  %1: free parameter, 0: fixed parameter

%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = 0.01:.001:.11;
searchGrid.beta = logspace(0,3,101);
searchGrid.gamma = 0.5;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0.02;  %ditto

%Perform fit
paramsValues = PAL_PFML_Fit(stimulusLevel,nCorrect, ...
    nTrials,searchGrid,paramsFree,p.Results.fitFunction);

% Turn off some Palamedes warnings
warnState = warning('off','PALAMEDES:convergeFail');

% Calculate SD if requested
if p.Results.calcSD
    nBootStrapsSD=400;
    paramsValuesSD = PAL_PFML_BootstrapNonParametric(...
        stimulusLevel, nCorrect, nTrials, [], paramsFree, nBootStrapsSD, ...
        p.Results.fitFunction,...
        'searchGrid',searchGrid);
else
    paramsValuesSD = [];
end

% Calculate p-value if requested
if p.Results.calcPValue
    nBootStrapsSD=1000;
        [~, pValue] = PAL_PFML_GoodnessOfFit(stimulusLevel, nCorrect, nTrials, ...
    paramsValues, paramsFree, nBootStrapsSD, p.Results.fitFunction, 'searchGrid', searchGrid);
else
    pValue = [];
end

% Restore the warning state
warning(warnState);

end
