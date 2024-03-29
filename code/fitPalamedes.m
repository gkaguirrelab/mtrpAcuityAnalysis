function [modelFitFunc, paramsValues, paramsValuesSD, pValue]  = fitPalamedes(axisAcuityData, position, varargin)
% Fit psychometric function to the acuity data at a position
%
% Syntax:
%   [paramsValues, modelFitFunc, paramsValuesSD, pValue]  = fitPalamedes(axisAcuityData, position)
%
% Description:
%   Uses the data structure axisAcuityData at specified positions to
%   calculate a psychometric function fit to the binned data using the
%   Palamedes toolbox.
%  
%   For the logisitic model fit, the parameters are:
%       alpha - half-way point between the max and min performance
%       beta - slope
%       gamma - guess rate
%       labda - lapse rate
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
%  'fitFunction'          - Function handle. Options include: @...
%                           PAL_Logistic, PAL_Gumbel, PAL_Weibull,
%                           PAL_Quick, PAL_logQuick, PAL_CumulativeNormal,
%                           PAL_HyperbolicSecant
%  'searchGrid'           - Structure. Fields depend upon the fitFunction.
%                           These are the ranges of values that are used
%                           for an initial, brute force search to
%                           initialize the fitting routine.
%  'calcSD'               - Logical. Controls if a non-parametric, boot-
%                           strap calculation of parameter SDs is performed
%  'calcPValue'           - Logical. Controls if a goodness-of-fit
%                           procedure is performed to obtain a p-value.
%
% Outputs:
%   modelFitFunc          - Handle to anonymous function that takes as
%                           input spatial frequency in cycles/deg and
%                           returns the expected percentage correct.
%   paramsValues          - 1xn vector of model fit parameter values.
%   paramsValuesSD        - 1xn vector of SD values for the params.
%   pValue                - Scalar. p-value of the model fit.
%
% Examples
%{
%}



%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = false;

% Required
p.addRequired('axisAcuityData',@isstruct);
p.addRequired('position', @(x)(isnumeric(x) | iscell(x)));

% Optional params
p.addParameter('fitFunction',@PAL_Logistic, @(x) (isa(x,'function_handle')));
p.addParameter('searchGrid',struct(...
    'alpha',-1:0.2:1,'beta',logspace(0,2,10),...
    'gamma',0:0.1:0.5,'lambda',0:0.025:0.1),@isstruct);
p.addParameter('calcSD',false, @islogical);
p.addParameter('calcPValue',false, @islogical);

%% Parse and check the parameters
p.parse(axisAcuityData, position, varargin{:});


%% Main

% Get bins
[binCenters,nCorrect,nTrials] = binTrials(axisAcuityData, position, varargin{:});

% Express stimulus level as the reciprocal of log10 binCenters
stimulusLevel = log10(1./binCenters);

% Perform fit
paramsValues = PAL_PFML_Fit(stimulusLevel, nCorrect, nTrials, ...
    p.Results.searchGrid, ...
    [1 1 1 1], ...
    p.Results.fitFunction, ...
    'guessLimits',[0 0.5],...
    'lapseLimits',[0 0.1]);

% Turn off some Palamedes warnings
warnState = warning('off','PALAMEDES:convergeFail');

% Calculate SD if requested
if p.Results.calcSD
    nBootStrapsSD=400;
    paramsValuesSD = PAL_PFML_BootstrapNonParametric(...
        stimulusLevel, nCorrect, nTrials, [], [1 1 1 1], nBootStrapsSD, ...
        p.Results.fitFunction,...
        'searchGrid',p.Results.searchGrid, ...
    'guessLimits',[0 0.5],...
    'lapseLimits',[0 0.1]);
else
    paramsValuesSD = [];
end

% Calculate p-value if requested
if p.Results.calcPValue
    nBootStrapsSD=1000;
        [~, pValue] = PAL_PFML_GoodnessOfFit(stimulusLevel, nCorrect, nTrials, ...
    paramsValues, [1 1 1 1], nBootStrapsSD, p.Results.fitFunction, 'searchGrid', p.Results.searchGrid);
else
    pValue = [];
end

% Create an anonymous function that takes cycles/deg input, converts to
% log10 reciprocal cycles/deg, and then returns the proportion correct.
modelFitFunc = @(paramsValues, x) p.Results.fitFunction(paramsValues,log10(1./x));

% Restore the warning state
warning(warnState);

end
