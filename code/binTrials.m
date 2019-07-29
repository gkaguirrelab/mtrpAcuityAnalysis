function [binCenters,nCorrect,nTrials] = binTrials(axisAcuityData, position, varargin)
% Place staircase performance vector into evenly (log) spaced bins
%
% Syntax:
%  [binCenters,nCorrect,nTrials] = binTrials(axisAcuityData)
%
% Description:
%   Given an axisAcuityData structure and key-value pairs that defined a
%   position, the routine will divide the set of trials at this location
%   into bins that are evenly log spaced and have the number of trials
%   specified by the nPerBin key-value parameter.
%
%   Derived from the function GetAggregatedStairTrials.m, contained in the
%   BrainardLabToolbox.
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
%  'nPerBin'              - Scalar or empty. The number of trials to 
%                           attempt to place within a bin. If empty, then
%                           the responses will be divided into nBins.
%  'nBins'                - Scalar.
%
% Outputs:
%   binCenters            - 1xn vector. The center of each bin in linear 
%                           spatial frequency units.
%   nCorrect              - 1xn vector. The number of correct responses in
%                           each bin, where n is the number of bins.
%   nTrials               - 1xn vector. The total number of trials in each
%                           bin.
%
% Examples:
%{
    % Bin data from a location from the first mat file in the data directory
    dataBasePath = getpref('mtrpAcuityAnalysis','mtrpCompiledDataPath');
    tmp = dir(fullfile(dataBasePath,'*_axisAcuityData.mat'));
    dataFileName = fullfile(tmp(1).folder,tmp(1).name);
    load(dataFileName,'axisAcuityData')
    [binCenters,nCorrect,nTrials] = binTrials(axisAcuityData);
%}


%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = true;

% Required
p.addRequired('axisAcuityData',@isstruct);
p.addRequired('position', @(x)(isnumeric(x) | iscell(x)));

% Optional params
p.addParameter('nPerBin', [], @(x)(isempty(x) | isscalar(x)));
p.addParameter('nBins', 10, @isscalar);


%% Parse and check the parameters
p.parse(axisAcuityData, position, varargin{:});


%% Obtain the vector of responses for this position
% Find the indices in axisAcuityData with stimuli at the specified location
% on the screen in degrees.
idx = getIndicies(axisAcuityData, position, varargin{:});
values = axisAcuityData.cyclesPerDeg(idx);
responses = axisAcuityData.response(idx);

% Handle the case of insufficient data
if sum(idx) < p.Results.nBins
    binCenters = nan(1,p.Results.nBins);
    nCorrect = nan(1,p.Results.nBins);
    nTrials = nan(1,p.Results.nBins);
    return
end

% How many points per bin?
if isscalar(p.Results.nPerBin)
    nPerBin = p.Results.nPerBin;
else
    nPerBin = ceil(length(responses)/p.Results.nBins);
end

% Conver the values to log spatial frequeny
logValues = log10(values);

% Perform the binning
[sortValues,index] = sort(logValues);
sortResponses = responses(index);
outIndex = 1;
bin = 1;
while (outIndex <= length(sortValues))
    logBinCenters(bin) = 0;
    nCorrect(bin) = 0;
    nTrials(bin) = 0;
    binCounter = 0;
    for i = 1:nPerBin
        logBinCenters(bin) = logBinCenters(bin) + sortValues(outIndex);
        if (sortResponses(outIndex) == 1)
            nCorrect(bin) = nCorrect(bin) + 1;
        end
        nTrials(bin) = nTrials(bin) + 1;
        binCounter = binCounter + 1;
        outIndex = outIndex + 1;
        if (outIndex > length(sortValues))
            break;
        end
    end
    logBinCenters(bin) = logBinCenters(bin)/binCounter;
    bin = bin + 1;
end

% Convert logBinCenters back to linear units of spatial frequency
binCenters = 10.^logBinCenters;

end

